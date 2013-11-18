$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'
SimpleCov.start do
  add_filter { |source| source.lines_of_code <= 3 }
  add_filter { |source| source.filename =~ /spec/ }

  add_group('Adapters') { |source| source.filename =~ /lib\/adapters/ }
  add_group('Interfaces') { |source| source.filename =~ /lib\/interfaces/ }
  add_group('Main Gem File') { |source| source.filename =~ %r!/lib/basquiat\.rb$! }
end

require 'yajl/json_gem'
require 'basquiat'

require 'support/simple_producer'
