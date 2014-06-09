require 'multi_json'
require 'naught'

require_relative 'basquiat/hash_refinements'
require_relative 'basquiat/configuration'
require_relative 'basquiat/adapters'
require_relative 'basquiat/version'
require_relative 'basquiat/interfaces/base'
require_relative 'basquiat/default_logger'


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
