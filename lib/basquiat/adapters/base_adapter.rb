module Basquiat
  module Adapters
    # Base implementation for an adapter
    module Base
      using Basquiat::HashRefinements

      def initialize
        @options = default_options
        @procs   = {}
        @retries = 0
      end

      # Used to set the options for the adapter. It is merged in
      # to the default_options hash.
      # @param [Hash] opts an adapter dependant hash of options
      def adapter_options(opts)
        @options.deep_merge(opts)
      end

      # Default options for the adapter
      # @return [Hash]
      def default_options
        {}
      end

      def update_config
      end

      def publish
      end

      def subscribe_to
      end

      def disconnect
      end

      def disconnected?
      end

      private
      attr_reader :procs, :options

      def logger
        Basquiat.configuration.logger
      end
    end
  end
end
