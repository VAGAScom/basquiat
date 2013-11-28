require_relative 'basquiat/adapters'
require_relative 'basquiat/version'
require_relative 'basquiat/interfaces/base'

module Basquiat
  def self.configuration
    Configuration.instance
  end

  class Configuration
    require 'singleton'
    include ::Singleton

    def queue_name=(value)
      @queue_name = value
    end

    def queue_name
      @queue_name ||= 'vagas.queue'
    end

    def exchange_name
      @exchange_name ||= 'vagas.exchange'
    end

    def exchange_name=(value)
      @exchange_name = value
    end
  end
end
