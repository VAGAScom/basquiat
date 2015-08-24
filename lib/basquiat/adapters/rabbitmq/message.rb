module Basquiat
  module Adapters
    class RabbitMq
      class Message < Basquiat::Adapters::BaseMessage
        attr_writer :routing_key
        attr_reader :delivery_info, :props
        alias_method :di, :delivery_info

        #@!attribute [r] delivery_info
        #  @return [Hash] RabbitMQ delivery_info.
        #@!attribute [r] props
        #  @return [Hash] RabbitMQ message properties, such as headers.

        def initialize(message, delivery_info = {}, props = {})
          super(message)
          @delivery_info = delivery_info
          @props         = props
          @action        = :ack
        end

        #@!attribute [rw] routing_key
        #  @param [String] key Overrides (but not overwrites) the delivery_info.routing_key.
        #  @return [String] returns either the set routing_key or the delivery_info routing_key
        def routing_key
          @routing_key || delivery_info.routing_key
        end

        # shorthand for delivery_info.delivery_tag
        def delivery_tag
          delivery_info.delivery_tag
        end

        #@!group Action Setters
        # Sets the action to be taken after processing to be an ack.
        # Here just in case as the default is to acknowledge the message.
        def ack
          @action = :ack
        end

        # Sets the action to be taken after processing to be an nack / reject
        def nack
          @action = :nack
        end

        # Sets the action to be taken after processing to be a requeue
        def requeue
          @action = :requeue
        end
        #@!endgroup
      end
    end
  end
end
