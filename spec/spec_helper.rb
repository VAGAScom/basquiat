$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'
SimpleCov.start do
  add_filter {|source| source.lines.size <= 3 }
end

require 'yajl/json_gem'
require 'basquiat'

require 'support/simple_producer'
