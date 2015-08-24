require 'delegate'
require 'basquiat/adapters/base_message'

module Basquiat
  module Adapters
    # Base implementation for an adapter
    class Base
      using Basquiat::HashRefinements

      class << self
        # A hash representing the registered requeue/acknowledge strategies
        # @return [Hash] the registered RequeueStrategies
        def strategies
          @strategies ||= {}
        end

        # Used to register a requeue/acknowledge strategy
        # @param [String,Symbol] config_name the named used on the config file for the Requeue Strategy
        # @param [Class] klass the class name.
        def register_strategy(config_name, klass)
          strategies[config_name.to_sym] = klass
        end

        # Return the Strategy Class registered on key
        # @param key [#to_sym] configured key for the wanted strategy
        # @return [Class] return the strategy class
        # @raise [Errors::StrategyNotRegistered] if it fails to find the key
        def strategy(key)
          strategies.fetch(key)
        rescue KeyError
          fail Basquiat::Errors::StrategyNotRegistered
        end
      end

      # @param procs [Hash] - it's a hash by default, but can be any object as in {RabbitMq#initialize}
      def initialize(procs: {})
        @options = base_options
        @procs   = procs
        @retries = 0
      end

      # Utility method to access the class instance variable
      def strategies
        self.class.strategies
      end

      # Used to set the options for the adapter. It is merged in
      # to the default_options hash.
      # @param [Hash] opts an adapter dependant hash of options
      def adapter_options(opts)
        @options.deep_merge(opts)
      end

      # Options for the adapter. It's already merged with the Configuration.adapter_options
      # @return [Hash] the full options hash
      def base_options
        default_options.merge(Basquiat.configuration.adapter_options)
      end

      # The adapter default options
      # @return [Hash]
      def default_options
        {}
      end

      # @!group Adapter specific implementations
      # @abstract Publish an event to the event stream
      def publish
        fail Basquiat::Errors::SubclassResponsibility
      end

      # @abstract subscribe_to the event stream
      def subscribe_to
        fail Basquiat::Errors::SubclassResponsibility
      end

      # @abstract Disconnect from the message queue
      def disconnect
        fail Basquiat::Errors::SubclassResponsibility
      end
      # @!endgroup

      private

      attr_reader :procs, :options
    end
  end
end
