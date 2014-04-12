# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'basquiat/version'

Gem::Specification.new do |spec|
  spec.name          = 'basquiat'
  spec.version       = Basquiat::VERSION
  spec.authors       = ['Marcello Rocha']
  spec.email         = %w(marcello.rocha@vagas.com.br)
  spec.description   = %q{Lib para abstrair a interação com diferentes serviços de messageria}
  spec.summary       = %q{Lib para abstrair a interação com diferentes serviços de messageria}
  spec.homepage      = 'http://vagas.com.br'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-bundler'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'guard-rubocop'
  spec.add_development_dependency 'bunny'
  spec.add_development_dependency 'stomp'
  spec.add_development_dependency 'yajl-ruby'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'metric_fu'
  spec.add_development_dependency 'rubocop'

  spec.add_dependency 'multi_json'
end
