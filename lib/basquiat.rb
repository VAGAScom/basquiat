require 'multi_json'
require 'basquiat/version'

require_relative 'adapters/null_adapter'

require_relative 'interfaces/base'
require_relative 'interfaces/producer'
require_relative 'interfaces/consumer'

module Basquiat
  def self.configuration
    Configuration.instance
  end

  class Configuration
    require 'singleton'
    include ::Singleton

    def exchange_name
      @exchange_name ||= 'vagas'
    end

    def exchange_name=(value)
      @exchange_name = value
    end
  end
end
