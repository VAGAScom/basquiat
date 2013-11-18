module Basquiat
  module Adapters
    class RabbitMq
      def connection_options(opts = {})
        @options = opts
      end

      def publish(event, message)
        self.connect
        exchange.publish(message, routing_key: event)
        self.disconnect
      end

      private
      def connection
        @connection = Bunny.new(opts)
      end

      def connect
        connection.start
      end

      def disconnect
        @connection.close_all_channels
        @connection.close
      end

      def exchange
        channel   = connection.create_channel
        @exchange = channel.topic(Basquiat.configuration.exchange_name, durable: true)
      end
    end
  end
end
