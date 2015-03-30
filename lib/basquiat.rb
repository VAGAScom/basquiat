require 'multi_json'
require 'naught'
require 'yaml'

require 'basquiat/support'
require 'basquiat/adapters'
require 'basquiat/version'
require 'basquiat/interfaces/base'

# Overall namespace And config class
module Basquiat
  class << self
    def reset
      @configuration = Configuration.new
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end
  end
end

require_relative 'basquiat/rails/railtie.rb' if defined?(Rails)
