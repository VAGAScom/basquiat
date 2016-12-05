# frozen_string_literal: true
require 'set'

module Basquiat
  # Base module used to extend the classes so that they will be able to use the event infrastructure
  module Base
    class << self

      # @api private
      def extended(klass)
        descendants.push klass
      end

      # @api private
      def descendants
        @descendants ||= []
      end

      # @api private
      def reconfigure_children
        descendants.each(&:reload_adapter_from_configuration)
      end
    end

    # @api private
    def reload_adapter_from_configuration
      @adapter = Kernel.const_get Basquiat.configuration.default_adapter
      adapter_options Basquiat.configuration.adapter_options
    end

    # @!attribute [rw] event_adapter
    #   @return [Basquiat::Adapter] the adapter instance for the current class
    #   @deprecated Please use {#adapter}

    # @!attribute [rw] adapter
    #   Initializes and return a instance of the default adapter specified on Basquiat.configuration.default_adapter
    #   @return [Basquiat::Adapter] the adapter instance for the current class
    def adapter=(adapter_klass)
      @adapter = adapter_klass.new
    end

    alias event_adapter= adapter=

    def adapter
      @adapter ||= Kernel.const_get(Basquiat.configuration.default_adapter).new
    end

    # @param opts [Hash] The adapter specific options. Defaults to Basquiat.configuration.adapter_options
    def adapter_options(opts = Basquiat.configuration.adapter_options)
      adapter.adapter_options(opts)
    end

    # Publishes the message of type event to the queue. Note that the message will be converted to a JSON
    # @param event [String] the event name
    # @param message [#to_json] Message to be JSONfied and sent to the Message Queue
    def publish(event, message)
      adapter.publish(event, message)
    end

    # Subscribe the event with the proc passed.
    # @param event_name [String] the event name
    # @param proc [Symbol, #call] the proc to be executed when the event is consumed.
    #   You can pass anything that answers to call or a symbol.
    #   If a symbol is passed it will try to look for a public class method of the same name.
    def subscribe_to(event_name, proc)
      proc = make_callable(proc)
      adapter.subscribe_to(event_name, proc)
    end

    # Utility method to force a disconnect from the message queue.
    # @note The adapter should reconnect automatically.
    def disconnect
      adapter.disconnect
    end

    # Utility method to check connection status
    # @return [truthy, falsey]
    def connected?
      adapter.connected?
    end

    # Starts the consumer loop
    # @param block [Boolean] If it should block the thread. The relevance of this is dictated by the adapter.
    #   Defaults to true.
    def listen(block: true, rescue_proc: Basquiat.configuration.rescue_proc)
      adapter.listen(block: block, rescue_proc: rescue_proc)
    end

    private

    def make_callable(proc)
      return proc if proc.respond_to? :call
      method(proc)
    end
  end
end
