require_relative 'basquiat/adapters'
require_relative 'basquiat/version'
require_relative 'basquiat/interfaces/base'
require 'multi_json'

module Basquiat
  def self.configuration
    Configuration.instance
  end

  # This singleton hold the gem overall configuration
  # TODO: I should change that to some kind of builder or kill it with fire
  class Configuration
    require 'singleton'
    include ::Singleton

    attr_writer :queue_name, :exchange_name

    def queue_name
      @queue_name ||= 'vagas.queue'
    end

    def exchange_name
      @exchange_name ||= 'vagas.exchange'
    end
  end
end
