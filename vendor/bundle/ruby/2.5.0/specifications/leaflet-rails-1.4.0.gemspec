# -*- encoding: utf-8 -*-
# stub: leaflet-rails 1.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "leaflet-rails".freeze
  s.version = "1.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Akshay Joshi".freeze]
  s.date = "2019-04-02"
  s.description = "This gem provides the leaflet.js map display library for your Rails 4/5 application.".freeze
  s.email = ["joshi.a@gmail.com".freeze]
  s.homepage = "".freeze
  s.licenses = ["BSD".freeze]
  s.rubyforge_project = "leaflet-rails".freeze
  s.rubygems_version = "2.7.6.2".freeze
  s.summary = "Use leaflet.js with Rails 4/5.".freeze

  s.installed_by_version = "2.7.6.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>.freeze, [">= 4.2.0"])
      s.add_development_dependency(%q<rspec>.freeze, ["<= 3.4.0"])
      s.add_development_dependency(%q<simplecov-rcov>.freeze, [">= 0"])
    else
      s.add_dependency(%q<rails>.freeze, [">= 4.2.0"])
      s.add_dependency(%q<rspec>.freeze, ["<= 3.4.0"])
      s.add_dependency(%q<simplecov-rcov>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<rails>.freeze, [">= 4.2.0"])
    s.add_dependency(%q<rspec>.freeze, ["<= 3.4.0"])
    s.add_dependency(%q<simplecov-rcov>.freeze, [">= 0"])
  end
end
