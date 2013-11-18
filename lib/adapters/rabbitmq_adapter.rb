module Basquiat
  module Adapters
    class RabbitMq
      def initialize
        @options = {}
      end

      def connection_options(opts)
        @options = opts
      end

      def publish(event, message)
        connect
        exchange.publish(message, routing_key: event)
        disconnect
      end

      private
      def connection
        @connection ||= Bunny.new(@options)
      end

      def connect
        connection.start
      end

      def disconnect
        connection.close_all_channels
        connection.close
        @channel, @exchange = nil, nil
      end

      def channel
        @channel ||= connection.create_channel
      end

      def exchange
        @exchange ||= channel.topic(Basquiat.configuration.exchange_name, durable: true)
      end
    end
  end
end
