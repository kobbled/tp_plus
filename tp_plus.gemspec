# encoding: utf-8
require File.expand_path('../lib/tp_plus/version', __FILE__)

Gem::Specification.new do |spec|
  spec.add_development_dependency 'rexical'
  spec.add_development_dependency 'racc'
  spec.add_development_dependency 'test-unit'

  spec.authors                   = ["Jay Strybis"]
  spec.email                     = ['jay.strybis@gmail.com']

  spec.name                      = 'tp_plus'
  spec.description               = %q{TP+}
  spec.summary                   = spec.description
  spec.homepage                  = 'http://github.com/onerobotics/tp_plus/'
  spec.licenses                  = ['MIT']
  spec.version                   = TPPlus::VERSION

  spec.files                     = %w(README.md Rakefile tp_plus.gemspec)
  spec.files                    += Dir.glob("lib/**/*.rb")
  spec.files                    += Dir.glob("test/**/*")
  spec.test_files                = Dir.glob("test/**/*")

  spec.require_paths             = ['lib']
  spec.required_rubygems_version = Gem::Requirement.new('>= 1.3.6')
end

