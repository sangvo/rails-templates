insert_into_file 'Gemfile', after: %r{gem 'bootsnap'.*\n} do
  <<~EOT
    gem 'i18n-js' # A library to provide the I18n translations on the Javascript
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

insert_into_file 'Gemfile', after: %r{gem 'pronto-reek'.*\n} do
  <<-EOT
  gem 'pronto-scss', require: false
  gem 'pronto-eslint_npm', require: false
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
