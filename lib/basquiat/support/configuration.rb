require 'basquiat/support/hash_refinements'
require 'naught'
require 'erb'

module Basquiat
  require 'logger'
  DefaultLogger = Naught.build { |config| config.mimic Logger }

  class Configuration
    using HashRefinements

    attr_writer :queue_name, :exchange_name, :logger, :environment

    def queue_name
      @queue_name || 'basquiat.queue'
    end

    def exchange_name
      @exchange_name || 'basquiat.exchange'
    end

    def logger
      @logger || DefaultLogger.new
    end

    def environment
      (@environment || ENV['BASQUIAT_ENV'] || 'development').to_sym
    end

    def config_file=(path)
      load_yaml(path)
      setup_basic_options
    end

    def adapter_options
      config.fetch(:adapter_options) { Hash.new }
    end

    def default_adapter
      config.fetch(:default_adapter) { Basquiat::Adapter::Test }
    end

    def reload_classes
      Basquiat::Base.descendants.each(&:reload_adapter_from_configuration)
    end

    private

    def config
      @yaml.fetch(environment)
    end

    def load_yaml(path)
      @yaml = YAML.load(ERB.new(IO.readlines(path).join).result).symbolize_keys
    end

    def setup_basic_options
      @queue_name    ||= config.fetch(:queue_name) { 'basquiat.exchange' }
      @exchange_name ||= config.fetch(:exchange_name) { 'basquiat.queue' }
    end
  end
end
