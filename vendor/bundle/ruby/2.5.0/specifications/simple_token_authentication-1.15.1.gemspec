# -*- encoding: utf-8 -*-
# stub: simple_token_authentication 1.15.1 ruby lib

Gem::Specification.new do |s|
  s.name = "simple_token_authentication".freeze
  s.version = "1.15.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Gonzalo Bulnes Guilpain".freeze]
  s.date = "2017-01-26"
  s.email = ["gon.bulnes@gmail.com".freeze]
  s.homepage = "https://github.com/gonzalo-bulnes/simple_token_authentication".freeze
  s.licenses = ["GPL-3.0+".freeze]
  s.rubygems_version = "2.7.6.2".freeze
  s.summary = "Simple (but safe) token authentication for Rails apps or API with Devise.".freeze

  s.installed_by_version = "2.7.6.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<actionmailer>.freeze, ["< 6", ">= 3.2.6"])
      s.add_runtime_dependency(%q<actionpack>.freeze, ["< 6", ">= 3.2.6"])
      s.add_runtime_dependency(%q<devise>.freeze, ["< 6", ">= 3.2"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<inch>.freeze, ["~> 0.4"])
      s.add_development_dependency(%q<activerecord>.freeze, ["< 6", ">= 3.2.6"])
      s.add_development_dependency(%q<mongoid>.freeze, ["< 7", ">= 3.1.0"])
      s.add_development_dependency(%q<appraisal>.freeze, ["~> 2.0"])
    else
      s.add_dependency(%q<actionmailer>.freeze, ["< 6", ">= 3.2.6"])
      s.add_dependency(%q<actionpack>.freeze, ["< 6", ">= 3.2.6"])
      s.add_dependency(%q<devise>.freeze, ["< 6", ">= 3.2"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
      s.add_dependency(%q<inch>.freeze, ["~> 0.4"])
      s.add_dependency(%q<activerecord>.freeze, ["< 6", ">= 3.2.6"])
      s.add_dependency(%q<mongoid>.freeze, ["< 7", ">= 3.1.0"])
      s.add_dependency(%q<appraisal>.freeze, ["~> 2.0"])
    end
  else
    s.add_dependency(%q<actionmailer>.freeze, ["< 6", ">= 3.2.6"])
    s.add_dependency(%q<actionpack>.freeze, ["< 6", ">= 3.2.6"])
    s.add_dependency(%q<devise>.freeze, ["< 6", ">= 3.2"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<inch>.freeze, ["~> 0.4"])
    s.add_dependency(%q<activerecord>.freeze, ["< 6", ">= 3.2.6"])
    s.add_dependency(%q<mongoid>.freeze, ["< 7", ">= 3.1.0"])
    s.add_dependency(%q<appraisal>.freeze, ["~> 2.0"])
  end
end
