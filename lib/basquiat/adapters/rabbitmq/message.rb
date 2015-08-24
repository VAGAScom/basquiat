module Basquiat
  module Adapters
    class RabbitMq
      class Message < Basquiat::Adapters::BaseMessage
        attr_reader :delivery_info, :props
        alias_method :di, :delivery_info
        # @!attribute [r] delivery_info
        #   @return [Hash] RabbitMQ delivery_info.
        # @!attribute [r] props
        #   @return [Hash] RabbitMQ message properties, such as headers.

        def initialize(message, delivery_info = {}, props = {})
          super(message)
          @delivery_info = delivery_info
          @props         = props
          @action        = :ack
        end

        # @!attribute [rw] routing_key
        #   It overrides (but not overwrites) the delivery_info routing_key
        #   @return [String] returns either the set routing_key or the delivery_info routing_key
        attr_writer :routing_key
        def routing_key
          @routing_key || delivery_info.routing_key
        end

        # Shorthand for delivery_info.delivery_tag
        def delivery_tag
          delivery_info.delivery_tag
        end
      end
    end
  end
end
