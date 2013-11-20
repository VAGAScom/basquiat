module Basquiat
  module Adapters
    class RabbitMq
      include Basquiat::Adapters::Base

      def default_options
        { host: 'localhost', port: 5672 }
      end

      def subscribe_to(event_name, &proc)
        procs[event_name] = proc
        bind_queue(event_name)
      end

      def publish(event, message)
        exchange.publish(message, routing_key: event)
        disconnect
      end

      def listen(lock)
        queue.subscribe(block: lock) do |di, prop, msg|
          procs[di.routing_key].call(msg)
        end
      end

      private
      def bind_queue(event_name)
        queue.bind(exchange, routing_key: event_name)
      end

      def queue
        @queue ||= channel.queue(Basquiat.configuration.queue_name, durable: true)
      end

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
        connect
        @channel ||= connection.create_channel
      end

      def exchange
        @exchange ||= channel.topic(Basquiat.configuration.exchange_name, durable: true)
      end
    end
  end
end
