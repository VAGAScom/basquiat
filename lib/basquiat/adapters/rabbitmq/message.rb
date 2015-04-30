require 'delegate'

module Basquiat::Adapters
  class RabbitMq
    class Message < SimpleDelegator
      attr_reader :delivery_info, :props
      alias :di :delivery_info

      def initialize(a_hash, delivery_info = {}, props = {})
        @message, @delivery_info, @props = a_hash, delivery_info, props
        @ack = true
        __setobj__(@message)
      end

      def ack?
        @ack
      end

      def unack
        @ack = false
      end
    end
  end
end