$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'

SimpleCov.start do
  add_filter { |source| source.lines_of_code <= 3 }
  add_filter { |source| source.filename =~ /spec/ }

  add_group('Adapters') { |source| source.filename =~ /basquiat\/adapters/ }
  add_group('Interfaces') { |source| source.filename =~ /basquiat\/interfaces/ }
  add_group('Support') { |source| source.filename =~ /basquiat\/support/ }
  add_group('Main Gem File') { |source| source.filename =~ %r{\/lib\/basquiat\.rb$} }
end

ENV['BASQUIAT_ENV'] = 'test'
require 'basquiat'

Basquiat.configure do |config|
  config.config_file = File.expand_path('../support/basquiat.yml', __FILE__)
  config.logger = Logger.new($stdout)
end

require 'support/shared_examples/basquiat_adapter_shared_examples'
