require_relative 'basquiat/adapters'
require_relative 'basquiat/version'
require_relative 'basquiat/interfaces/base'
require_relative 'basquiat/interfaces/consumer'
require 'multi_json'

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
    attr_writer :queue_name, :exchange_name

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
  end
end
