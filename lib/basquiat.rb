require 'multi_json'
require 'basquiat/version'

module Basquiat
  def configuration
    Configuration.instance
  end

  class Configuration
    require 'singleton'
    include ::Singleton

    def exchange_name
      @exchange_name ||= 'vagas'
    end

    def exchange_name=(value)
      @exchange_name = String(value)
    end
  end
end
