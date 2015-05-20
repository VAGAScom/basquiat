module Basquiat
  module Adapters
    class RabbitMq
      class BasicAcknowledge < BaseStrategy
        def run(message)
          yield
          send(message.action, message.di.delivery_tag)
        end
      end
    end
  end
end
