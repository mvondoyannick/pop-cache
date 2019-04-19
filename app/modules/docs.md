# POP CASH LIBS  & FUNCTIONS API & DESCRPTION

# LIBS & GEMFILES UTILISES DANS CE PROJET
```ruby
ruby '2.5.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.2'
# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.4.4', '< 0.6.0'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
#simple_form rails
gem 'simple_form'
#country select
gem 'country_select'
#installing devise
gem 'devise'
#installation de la maps leaflet rails
gem 'leaflet-rails'
#installing httparty
gem 'httparty'
#install geocoder
gem 'geocoder'
#json web token
gem 'jwt'
#gestion du qrcode
gem 'rqrcode'
#gestion du QRcode au format png
gem 'rqrcode_png'
#using dragonfly
gem 'dragonfly', '~> 1.2.0'
#AES for encrypt decrypt
gem 'aes'
#gestion des email
gem 'mail_form'
#installing faraday http gem
gem 'faraday'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'duktape'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem "better_errors"
  gem "binding_of_caller"
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
```
## Ce docurement presente l'ensemble des fonctionnalités technique et API de POP Cash
### last update : 01-04-19 by mvondoyannick@gmail.com
## 1. Authenticate user module (Module)

Permet d'authentifier un client enregistré sur la plateforme
```ruby
    Client::auth_user(phone, pwd, hashawait)
    return :name, :second_name, :token
```

## 2. Cancel retrait argent (Module)

```ruby
    Client::cancelRetrait(phone, pwd, hashawait)
    return :boolean, :mesage_status
```

## 3. Obtenir le montant contenu dans le compte client (Module)

```ruby
    Client::get_balence(phone, pwd)
    return :message_status
    phone:integer, pwd:string
```

## 4. Obtenir le montant avant chaque retrait du compte client (Module)

```ruby
    Client::get_balance_retrait(phone, amount)
    return :boolean
```

## 5. Permet d'initialiser la procedure de retrait d'argent du compte client (Module)

```ruby
    Client::init_retrait(phone, amount)
    return :boolean, :message_status
```

# GESTION DES FRAUDES
La gestion des fraudes est appliquée sur differents aspects, notamment:
- 
## 5. Permet d'initialiser la procedure de retrait d'argent du compte client (Module)

```ruby
    Client::init_retrait(phone, amount)
    return :boolean, :message_status
```
