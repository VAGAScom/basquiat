module Basquiat
  class Producer
    include Basquiat::Base

    def self.publish(event, message)
      adapter.publish(event, message)
    end
  end
end
