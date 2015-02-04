# encoding: utf-8
require File.expand_path('../lib/tp_plus/version', __FILE__)

Gem::Specification.new do |spec|
  spec.add_development_dependency 'rexical', '~> 1.0'
  spec.add_development_dependency 'racc', '~> 1.4'
  spec.add_development_dependency 'test-unit', '~> 2.0'

  spec.authors                   = ["Jay Strybis"]
  spec.email                     = ['jay.strybis@gmail.com']

  spec.name                      = 'tp_plus'
  spec.description               = %q{TP+}
  spec.summary                   = 'A higher-level abstraction of FANUC TP'
  spec.homepage                  = 'http://github.com/onerobotics/tp_plus/'
  spec.licenses                  = ['MIT']
  spec.version                   = TPPlus::VERSION

  spec.executables               = ['tpp']
  spec.files                     = %w(README.md Rakefile tp_plus.gemspec)
  spec.files                    += Dir.glob("lib/**/*.rb")
  spec.files                    += Dir.glob("test/**/*")
  spec.test_files                = Dir.glob("test/**/*")

  spec.require_paths             = ['lib']
  spec.required_rubygems_version = Gem::Requirement.new('>= 1.3.6')
end

