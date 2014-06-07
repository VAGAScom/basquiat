require 'multi_json'
require 'naught'

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

  class Configuration
    attr_writer :queue_name, :exchange_name, :logger

    def initialize
      @queue_name    = 'vagas.queue'
      @exchange_name = 'vagas.exchange'
    end

    def queue_name
      @queue_name || 'vagas.queue'
    end

    def exchange_name
      @exchange_name || 'vagas.exchange'
    end

    def logger
      @logger || DefaultLogger.new
    end

    # def environment
    #   @environment || Env['BASQUIAT_ENV'] || 'development'
    # end

    def config_file=(path)
      # Load the YAML
      # Set the whole thing up
      # Using the options from the file
    end
  end
end
