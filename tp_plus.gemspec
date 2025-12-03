# encoding: utf-8
require File.expand_path('../lib/tp_plus/version', __FILE__)

Gem::Specification.new do |spec|
  spec.add_development_dependency 'benchmark-ips', '~> 2.1'
  spec.add_development_dependency 'psych', '~>3.0'
  spec.add_development_dependency 'rexical', '~> 1.0'
  spec.add_development_dependency 'racc', '~> 1.6.1'
  spec.add_development_dependency 'test-unit', '~> 3.0'
  spec.add_development_dependency 'rake', '~> 12.3.3'
  spec.add_development_dependency 'rdoc'
  spec.add_development_dependency 'matrix', '~> 0.4.2'
  spec.add_development_dependency 'ppr'

  spec.authors                   = ["Jay Strybis", "Matt Dewar"]
  spec.email                     = ['mattpdewar@gmail.com']

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

