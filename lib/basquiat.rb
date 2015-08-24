require 'multi_json'
require 'naught'
require 'yaml'

require 'basquiat/support'
require 'basquiat/errors'
require 'basquiat/adapters'
require 'basquiat/version'
require 'basquiat/interfaces/base'

# Overall namespace And config class
module Basquiat
  class << self
    # resets the gems configuration. Useful for testing and not much else
    def reset
      @configuration = Configuration.new
    end

    # @return [Configuration] returns or initializes the Configuration object
    def configuration
      @configuration ||= Configuration.new
    end

    # @yield [Configuration] setup the gem's configuration as a block
    # @yieldparam [Configuration] configuration
    def configure
      yield configuration
    end

    # @return [Logger] shorthand for configuration.logger
    def logger
      configuration.logger
    end
  end
end

require_relative 'basquiat/rails/railtie.rb' if defined?(Rails)
