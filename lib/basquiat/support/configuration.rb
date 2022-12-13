# frozen_string_literal: true

require 'naught'
require 'erb'
require 'basquiat/support/hash_refinements'

module Basquiat
  require 'logger'
  DefaultLogger = Naught.build { |config| config.mimic Logger }

  class Configuration
    using HashRefinements

    def initialize
      @yaml        = {}
      @rescue_proc = lambda do |exception, message|
        logger.error do
          { exception: exception, backtrace: exception.backtrace, message: message }.to_json
        end
        raise exception
      end
    end

    # @!attribute queue_name
    #   @return [String] the queue name. Defaults to 'basquiat.queue'
    # @!attribute exchange_name
    #   @return [String] the exchange name. Defaults to 'basquiat.exchange'
    # @!attribute logger
    #   @return [Logger] return the application logger. Defaults to {DefaultLogger}.
    # @!attribute environment
    #   @return [Symbol] return the set environment or the value of the 'BASQUIAT_ENV' environment variable
    #     or :development
    attr_writer :queue_name, :exchange_name, :logger, :environment

    # @!attribute connection - Makes Basquiat to use a provided connection
    #   @return [Object] the provided connection
    # @!attribute rescue_proc
    #   @return [#call] return the callable to be executed when some exception is thrown. The callable receives the
    #     exception and message
    attr_accessor :connection, :rescue_proc

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

    # Loads a YAML file with the configuration options
    # @param path [String] the path of the configuration file
    def config_file=(path)
      load_yaml(path)
      setup_basic_options
    end

    # @return [Hash] return the configured adapter options. Defaults to an empty {::Hash}
    def adapter_options
      config.fetch(:adapter_options) { {} }
    end

    # @return [String] return the configured default adapter. Defaults to {Adapters::Test}
    def default_adapter
      config.fetch(:default_adapter) { 'Basquiat::Adapters::Test' }
    end

    # Used by the railtie. Forces the reconfiguration of all extended classes
    def reload_classes
      Basquiat::Base.reconfigure_children
    end

    private

    def config
      @yaml.fetch(environment, {})
    end

    def load_yaml(path)
      @yaml = YAML.safe_load(ERB.new(IO.readlines(path).join).result, aliases: true, permitted_classes: [Symbol]).symbolize_keys
    end

    def setup_basic_options
      @queue_name ||= config.fetch(:queue_name) { 'basquiat.exchange' }
      @exchange_name ||= config.fetch(:exchange_name) { 'basquiat.queue' }
    end
  end
end
