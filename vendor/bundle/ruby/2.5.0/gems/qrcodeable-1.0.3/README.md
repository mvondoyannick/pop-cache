# Qrcodeable

Add qrcode support to your activerecord model.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'qrcodeable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install qrcodeable

## Usage

Add

```ruby
qrcodeable
```

to your model. You will need to add column `key` in your model using migration.

Options :

- `identifier`. A QRCode value used to generate QRCOde. Default value is `:key`.
- `print_path`. Default direcory for this gem. Default value is `"qrcodes/download"`.
- `expire_mode`. Set to `true` if you want QRCode have expired_date. Default value is `false`. 
- `expire_column`. You will need to add column `:expired_date` using migration if you set `expire_mode` to `true`. Default value is `:expired_date`.

Available methods :

- `print_qrcode` print qrcode, return `print_path`. You can add to callback or event send_file from controller.
- `qrcode_path` show qrcode_path, return `print_path`.
- `qrcode_expired?` check whether it is expired or not, return boolean.

## Examples

### Example 1

```ruby
qrcodeable
```

- identifier `:key`
- print_path `"qrcodes/download"`
- cannot expiring

### Example 2

```ruby
qrcodeable identifier: :code
```

- identifier `:code`
- print_path `"qrcodes/download"`
- cannot expiring

### Example 3

```ruby
qrcodeable identifier: :code, print_path: "public/downloads"
```

- identifier `:code`
- print_path `"public/download"`
- cannot expiring

### Example 4

```ruby
qrcodeable expired_mode: true
```

- identifier `:key`
- print_path `"qrcodes/download"`
- can expiring
- expire_colum `:expired_date`

### Example 5

```ruby
qrcodeable expired_mode: true, expire_column: :due_date
```

- identifier `:key`
- print_path `"qrcodes/download"`
- can expiring
- expire_colum `:due_date`

### Example 6
```ruby
class Product < ApplicationRecord
  qrcodeable expired_mode: true
end

@product = Product.new(name: "Yellow Jacket", key: "1234567890", expired_date: (Time.now+5.days))

@product.print_qrcode

@product.qrcode_path

@product.qrcode_expired?

```

## TODO:

- Complete rspec
- Create dummy rails app
- Add generators for migration
- Add support for other ORM

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yunanhelmy/qrcodeable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

