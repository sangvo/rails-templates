require 'shellwords'

# Variables
APP_NAME = app_name
# Transform the app name from slug to human-readable name e.g. nimble-web -> Nimble
APP_NAME_HUMANIZED = app_name.split(/[-_]/).map(&:capitalize).join(' ').gsub(/ Web$/, '')
DOCKER_REGISTRY_HOST = 'docker.io'.freeze
DOCKER_IMAGE = "nimblehq/#{APP_NAME}".freeze
RUBY_VERSION = '2.7.2'.freeze
POSTGRES_VERSION = '12.1'.freeze
REDIS_VERSION = '5.0.7'.freeze
# Variants
API_VARIANT = options[:api] || ENV['API'] == 'true'
WEB_VARIANT = !API_VARIANT
# Addons
DEFAULT_ADDONS = {
  docker: 'Docker',
  heroku: 'Heroku',
  github: 'Github along with Github Action'
}.freeze

if WEB_VARIANT
  NODE_VERSION='14.15.4'.freeze
  NODE_SOURCE_VERSION='14'.freeze # Used in Dockerfile https://github.com/nodesource/distributions
end

def apply_template!(template_root)
  use_source_path template_root

  delete_test_folder

  template 'Gemfile.tt', force: true

  apply 'config/initializers/backtrace_silencers.rb'

  copy_file '.flayignore'
  copy_file 'Dangerfile'
  copy_file '.rubocop.yml'
  copy_file '.reek.yml'

  template '.ruby-gemset.tt'
  template '.ruby-version.tt', force: true
  copy_file '.editorconfig'
  copy_file 'Procfile'
  copy_file 'Procfile.dev'
  template 'README.md.tt', force: true

  apply 'bin/template.rb'
  apply 'config/template.rb'
  apply '.gitignore.rb'

  after_bundle do
    use_source_path template_root

    # Stop the spring before using the generators as it might hang for a long time
    # Issue: https://github.com/rails/spring/issues/486
    run 'spring stop'

    apply 'spec/template.rb'
  end

  # Add-ons - [Default]
  DEFAULT_ADDONS.each_key do |addon|
    apply ".template/addons/#{addon.to_s}/template.rb"
  end

  post_default_addons_install

  # Add-ons - [Optional]
  apply '.template/addons/semaphore/template.rb' if yes?(install_addon_prompt('SemaphoreCI'))
  apply '.template/addons/nginx/template.rb' if yes?(install_addon_prompt('Nginx'))
  apply '.template/addons/phrase_app/template.rb' if yes?(install_addon_prompt('PhraseApp'))
  apply '.template/addons/devise/template.rb' if yes?(install_addon_prompt('Devise'))

  # Variants
  apply '.template/variants/api/template.rb' if API_VARIANT
  apply '.template/variants/web/template.rb' if WEB_VARIANT

  # A list necessary jobs that run before complete, ex: Fixing rubocop on Ruby files that generated by Rails
  apply '.template/hooks/before_complete/template.rb'
end

# Set Thor::Actions source path for looking up the files
def source_paths
  @source_paths
end

# Prepend the required paths to the source paths to make the template files in those paths available
def use_source_path(source_path)
  @source_paths.unshift(source_path)
end

def remote_repository
  require 'tmpdir'
  tempdir = Dir.mktmpdir('rails-templates')
  at_exit { FileUtils.remove_entry(tempdir) }

  git clone: [
    '--quiet',
    'https://github.com/nimblehq/rails-templates.git',
    tempdir
  ].map(&:shellescape).join(' ')

  if (branch = __FILE__[%r{rails-templates/(.+)/template.rb}, 1])
    Dir.chdir(tempdir) { git checkout: branch }
  end

  tempdir
end

def delete_test_folder
  FileUtils.rm_rf('test')
end

def install_addon_prompt(addon)
  "Would you like to add the #{addon} addon? [Yn]"
end

def print_error_message
  puts <<~EOT
    #{'=' * 80}

    There are some errors when templating the application, Please fix them manually:

    #{@template_errors}
    #{'=' * 80}
  EOT
end

def post_default_addons_install
  addons = ""
  DEFAULT_ADDONS.each_value do |addon|
    addons << "* #{addon}\n  "
  end

  puts <<-EOT
  These default addons were installed:
  #{addons}
  EOT
end

# Init the source path
@source_paths ||= []

# Setup the template root path
# If the template file is the url, clone the repo to the tmp directory
template_root = __FILE__ =~ %r{\Ahttps?://} ? remote_repository : __dir__
use_source_path template_root

# Init the template errors
require "#{template_root}/.template/lib/template/errors"
@template_errors = Template::Errors.new

if ENV['ADDON']
  addon_template_path = ".template/addons/#{ENV['ADDON']}/template.rb"

  abort 'This addon is not supported' unless File.exist?(File.expand_path(addon_template_path, template_root))

  apply addon_template_path
else
  apply_template!(template_root)
end

print_error_message unless @template_errors.empty?
