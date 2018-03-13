# frozen_string_literal: true

module Basquiat
  module Adapters
    class RabbitMq
      class BasicAcknowledge < BaseStrategy
        def run(message)
          yield
          public_send(message.action, message)
        end
      end
    end
  end
end
