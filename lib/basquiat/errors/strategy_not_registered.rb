module Basquiat
  module Errors
    class StrategyNotRegistered < RuntimeError
      def initialize(symbol)
        @symbol = symbol
        super()
      end

      def message
        "No matching requeue strategy registered as :#{@symbol}"
      end
    end
  end
end
