module Basquiat
  module Adapters
    module Base
      def initialize
        @options = default_options
        @procs = Hash.new
      end

      # Used to set the options for the adapter. It is merged in
      # to the default_options hash.
      # @param [Hash] opts an adapter dependant hash of options
      def adapter_options(opts)
        options.merge! opts
      end

      # Default options for the adapter
      # @return [Hash]
      def default_options
        {}
      end

      def publish; end

      def subscribe_to; end

      private
      def procs
        @procs
      end

      def options
        @options
      end
    end
  end
end
