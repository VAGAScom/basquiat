module Basquiat
  class Producer
    include Basquiat::Base

    def self.publish(event, message)
      adapter.publish(message, routing_key: event)
    end
  end
end
