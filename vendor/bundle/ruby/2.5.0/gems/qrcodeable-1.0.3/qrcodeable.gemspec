# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'qrcodeable/version'

Gem::Specification.new do |spec|
  spec.name          = "qrcodeable"
  spec.version       = Qrcodeable::VERSION
  spec.authors       = ["yunanhelmy"]
  spec.email         = ["m.yunan.helmy@gmail.com"]

  spec.summary       = "Add qrcode support to your activerecord model."
  spec.description   = "Add qrcode support to your activerecord model."
  spec.homepage      = "https://github.com/yunanhelmy/qrcodeable"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib", "lib/qrcodeable"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_dependency "activesupport", ">= 4.2.6"
  spec.add_dependency "rqrcode", ">= 0.10.1"
end
