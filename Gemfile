source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

#ruby '2.5.5'
ruby '2.6.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.0'
# Use mysql as the database for Active Record
 gem 'mysql2', '>= 0.4.4', '< 0.6.0'
#gem 'sqlite3'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
#simple_form rails
gem 'simple_form'
#chartjs adding https://github.com/airblade/chartjs-ror
gem 'chartjs-ror'
# for short url
gem 'googl'
# For OTP, One Tome Password
gem 'rotp'
#country select
gem 'country_select'
#for cron job
gem 'whenever', require: false
#installing devise
gem 'devise'
#adding rack-core from https://github.com/cyu/rack-cors
gem 'rack-cors'
#generation des fakes datas
gem 'faker'
#devise authentication gem from https://github.com/gonzalo-bulnes/simple_token_authentication
gem 'simple_token_authentication', '~> 1.0'
#installation de la maps leaflet rails
gem 'leaflet-rails'
#installing httparty
gem 'httparty'
#install geocoder
gem 'geocoder'
#json web token
gem 'jwt'
#sending Email over Heroku
gem 'sendgrid-ruby'
#insert table print
gem "table_print"
#gestion du qrcode
gem 'rqrcode'
#gestion du QRcode au format png
gem 'rqrcode_png'
#using dragonfly
gem 'dragonfly', '~> 1.2.0'
#AES for encrypt decrypt https://github.com/chicks/aes
gem 'aes'
# Adding bootstrap
gem 'bootstrap', '~> 4.3.1'
# Jquery-rails
gem 'jquery-rails'
# adding fontawesome
gem "font-awesome-rails"
#installing faraday http gem
gem 'faraday'
#genere le qrcode comme je veux https://github.com/yunanhelmy/qrcodeable
gem 'qrcodeable'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
#gem 'duktape'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5.2.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Sidekiq for background job
gem 'sidekiq'
# chartjs rails
gem 'chart-js-rails'
# serviceworker-rails for PWA
gem 'serviceworker-rails'
#adding pusher for realtime
gem 'pusher'
# adding money rails https://github.com/RubyMoney/money-rails
gem 'money-rails', '~>1.12'
# adding breadcrumb on rails https://github.com/weppos/breadcrumbs_on_rails
#gem "breadcrumbs_on_rails"
# adding prawn for generating PDF files
gem 'prawn'
#adding tesseract for extract informations into cni picture file
# gem 'tesseract-ocr'
# cheking valid IPAdress
gem 'ipaddress'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3', '~> 1.4'
  gem 'pg'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem "better_errors"
  gem "binding_of_caller"
  gem "parallel"
  gem "rails-erd"
  #rails security scanner https://brakemanscanner.org/docs/quickstart/
  gem "brakeman"
  #rgem "appengine", "~> 0.4.1"
  gem 'solargraph'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'chromedriver-helper'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
#gem 'pg'