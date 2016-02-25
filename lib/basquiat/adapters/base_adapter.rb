# frozen_string_literal: true
require 'delegate'
require 'basquiat/adapters/base_message'

module Basquiat
  module Adapters
    # Base implementation for an adapter in uses {HashRefinements} internally.
    class Base
      using Basquiat::HashRefinements

      class << self
        # A hash representing the registered requeue/acknowledge strategies
        # @return [Hash] the registered RequeueStrategies
        def strategies
          @strategies ||= {}
        end

        # Used to register a requeue/acknowledge strategy
        # @param config_name [#to_sym] the named used on the config file for the Requeue Strategy
        # @param klass [Class] the class name.
        def register_strategy(config_name, klass)
          strategies[config_name.to_sym] = klass
        end

        # Return the Strategy Class registered on given key
        # @param key [#to_sym] configured key for the wanted strategy
        # @return [Class] the strategy class
        # @raise [Errors::StrategyNotRegistered] if it fails to find the key
        def strategy(key)
          strategies.fetch(key)
        rescue KeyError
          raise Basquiat::Errors::StrategyNotRegistered
        end
      end

      # @param procs [Object]
      #   It's a hash by default, but usually will be superseded by the adapter implementation
      def initialize(procs: {})
        @options = base_options
        @procs   = procs
        @retries = 0
      end

      # Utility method to access the class instance variable
      def strategies
        self.class.strategies
      end

      # Allows the #base_options to be superseded on the local level
      #
      # You could have configured an exchange_name (on a config file) to +'awesome.sauce'+,
      # but on this object you'd want to publish your messages to the +'killer.mailman'+ exchange.
      # @example
      #   class Mailmail
      #     extend Basquiat::Base
      #     adapter_options {exchange: {name: 'killer.mailman'}}
      #   end
      #
      # @param [Hash] opts an adapter dependant hash of options
      def adapter_options(opts)
        @options.deep_merge(opts)
      end

      # The default adapter options, merged with the {Basquiat::Configuration#adapter_options}. Used internally.
      # @api private
      # @return [Hash] the full options hash
      # @todo rename this method
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
        raise Basquiat::Errors::SubclassResponsibility
      end

      # @abstract subscribe_to the event stream
      def subscribe_to
        raise Basquiat::Errors::SubclassResponsibility
      end

      # @abstract Disconnect from the message queue
      def disconnect
        raise Basquiat::Errors::SubclassResponsibility
      end
      # @!endgroup

      private

      attr_reader :procs, :options
    end
  end
end
