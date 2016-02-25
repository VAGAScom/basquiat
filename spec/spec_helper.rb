# frozen_string_literal: true
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'codeclimate-test-reporter'
require 'simplecov'

CodeClimate::TestReporter.start

SimpleCov.start do
  add_filter { |source| source.lines_of_code <= 3 }
  add_filter { |source| source.filename =~ /spec/ }

  add_group('Adapters') { |source| source.filename =~ %r{lib/basquiat/adapters} }
  add_group('RabbitMQ') { |source| source.filename =~ %r{lib/basquiat/adapters/rabbitmq} }
  add_group('Errors') { |source| source.filename =~ %r{lib/basquiat/errors} }
  add_group('Interfaces') { |source| source.filename =~ %r{lib/basquiat/interfaces} }
  add_group('Main') { |source| source.filename =~ %r{lib/basquiat\.rb$} }
  add_group('Support') { |source| source.filename =~ %r{lib/basquiat/support} }
end

ENV['BASQUIAT_ENV'] = 'test'
require 'basquiat'

require 'support/shared_examples/basquiat_adapter_shared_examples'
require 'support/rabbitmq_queue_matchers'
