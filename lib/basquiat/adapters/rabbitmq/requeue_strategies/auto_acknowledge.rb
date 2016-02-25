# frozen_string_literal: true
module Basquiat
  module Adapters
    class RabbitMq
      class AutoAcknowledge < BaseStrategy
        def self.session_options
          { consumer: { manual_ack: false } }
        end

        def run(*)
          yield
        end
      end
    end
  end
end
