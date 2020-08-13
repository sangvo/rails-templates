insert_into_file 'Gemfile', after: %r{gem 'bootsnap'.*\n} do
  <<~EOT
    gem 'i18n-js', '3.5.1' # A library to provide the I18n translations on the Javascript
  EOT
end

insert_into_file 'Gemfile', after: %r{gem 'pundit'.*\n} do
  <<~EOT

    # Assets
    gem 'webpacker', '4.0' # Transpile app-like JavaScript
    gem 'sass-rails' # SASS
  EOT
end

############################
# Group: :development, :test
############################

insert_into_file 'Gemfile', after: %r{gem 'letter_opener'.*\n} do
  <<-EOT
  gem 'sassc-rails' # Gem to generate scss source maps.
  EOT
end

insert_into_file 'Gemfile', after: %r{gem 'rubocop-rails', require: false.*\n} do
  <<-EOT
  gem 'danger-slim_lint' # Lint Slim template files.
  gem 'danger-eslint' # Eslint
  EOT
end

##############
# Group: :test
##############

insert_into_file 'Gemfile', after: %r{gem 'rspec-retry'.*\n} do
  <<-EOT
  gem 'capybara', '>= 2.15' # Integration testing
  gem 'webdrivers' # Run Selenium tests more easily with automatic installation and updates for all supported webdrivers
  EOT
end
