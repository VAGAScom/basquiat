module Basquiat
  module Errors
    class StrategyNotRegistered < StandardError
      def initialize(symbol)
        super()
        @symbol = symbol
      end

      def message
        "No matching requeue strategy registered as :#{@symbol}"
      end
    end
  end
end
