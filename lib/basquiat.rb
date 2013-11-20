require 'multi_json'
require 'basquiat/version'

require_relative 'adapters/base_adapter'
require_relative 'adapters/test_adapter'

require_relative 'interfaces/base'

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
