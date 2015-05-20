module Basquiat
  module Adapters
    class RabbitMq
      class Message < Basquiat::Adapters::BaseMessage
        attr_reader :delivery_info, :props
        alias_method :di, :delivery_info

        def initialize(message, delivery_info = {}, props = {})
          super(message)
          @delivery_info = delivery_info
          @props         = props
          @action        = :ack
        end

        def routing_key
          delivery_info.routing_key
        end

        def delivery_tag
          delivery_info.delivery_tag
        end

        def ack
          @action = :ack
        end

        def unack
          @action = :unack
        end
      end
    end
  end
end
