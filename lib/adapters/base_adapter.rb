module Basquiat
  module Adapters
    module Base
      def initialize
        @options = default_options
      end

      def adapter_options(opts)
        options.merge! opts
      end

      private
      def options
        @options
      end
    end
  end
end
