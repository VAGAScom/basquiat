# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'basquiat/version'

Gem::Specification.new do |spec|
  spec.name        = 'basquiat'
  spec.version     = Basquiat::VERSION
  spec.authors     = ['Marcello "mereghost" Rocha']
  spec.email       = %w(marcello.rocha@gmail.com.br)
  spec.description = <<EOD
Basquiat is a library that intends to abstract all the complexity of working with message queues
EOD
  spec.summary  = 'A pluggable library that aims to hide message queue complexity'
  spec.homepage = 'http://github.com/VAGAScom/basquiat'
  spec.license  = 'MIT'

  spec.files         = `git ls-files`.split($RS).reject { |f| f =~ /^\.|docker/ }
  spec.executables   = spec.files.grep(%r{/^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-bundler'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'guard-rubocop'
  spec.add_development_dependency 'guard-yard'
  spec.add_development_dependency 'bunny'
  spec.add_development_dependency 'yajl-ruby'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'metric_fu'
  spec.add_development_dependency 'codeclimate-test-reporter'
  spec.add_development_dependency 'yard'

  spec.add_dependency 'multi_json'
  spec.add_dependency 'naught'
end
