# frozen_string_literal: true

require 'multi_json'
require 'naught'
require 'yaml'
require 'dry-configurable'
require 'logger'

require 'basquiat/support'
require 'basquiat/errors'
require 'basquiat/adapters'
require 'basquiat/version'
require 'basquiat/base'

# Overall namespace config class
module Basquiat
  extend Dry::Configurable

  # The default logger that's only a Mimic of a real [Logger] instance.
  DefaultLogger = Naught.build { |config| config.mimic Logger }

  # The default behaviour is to log the error and re-raise the exception during the event loop.
  DEFAULT_RESCUE_PROC = lambda do |exception, message|
    logger.error do
      { exception: exception, stack_trace: exception.stack_trace, message: message }.to_json
    end
    raise exception
  end

  setting :exchange_name, 'basquiat.exchange'
  setting :queue_name, 'basquiat.queue'
  setting :default_adapter, 'Basquiat::Adapters::Test' # TODO: Remove 'magic constant finder'
  setting :adapter_options, Hash[]
  setting :logger, DefaultLogger.new
  setting :rescue_proc, DEFAULT_RESCUE_PROC

  class << self
    # @!method configure(&block)
    #   Main method used to configure the library
    #   the object responds to the following methods:
    #   @param [String] exchange_name= name to be used for the default _exchange_
    #   @param [String] queue_name= name to be used for the default _queue_
    #   @param [String, Class] default_adapter=
    #   @param [Hash] adapter_options=
    #   @param [#call] rescue_proc=
    #   @yields a configuration object

    # resets the library configuration. Useful for testing and not much else
    def reset
      remove_instance_variable :@_config if @_config
    end

    # @return [Logger] shorthand for configuration.logger
    def logger
      config.logger
    end

    alias configuration config

    def load_configuration(file)
      yaml = YAML.safe_load(ERB.new(IO.readlines(file).join).result)
      yaml = yaml.fetch(ENV['BASQUIAT_ENV'])
      configure do |conf|
        yaml.each_pair do |key, value|
          conf.send("#{key.to_sym}=", value) # TODO: symbolize_values
        end
      end
    end
  end
end
