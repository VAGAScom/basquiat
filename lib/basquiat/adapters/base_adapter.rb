module Basquiat
  module Adapters
    module Base
      def initialize
        @options = default_options
        @procs = Hash.new
      end

      def adapter_options(opts)
        options.merge! opts
      end

      def default_options
        {}
      end

      def publish(event, message, single_message = true); end

      def subscribe_to(event_name, &proc); end

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
