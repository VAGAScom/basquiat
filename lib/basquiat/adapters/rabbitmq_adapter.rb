require 'bunny'

module Basquiat
  module Adapters
    # The RabbitMQ adapter for Basquiat
    class RabbitMq
      include Basquiat::Adapters::Base

      def default_options
        { server:   { host: 'localhost', port: 5672 },
          queue:    { name: Basquiat.configuration.queue_name, options: { durable: true } },
          exchange: { name: Basquiat.configuration.exchange_name, options: { durable: true } } }
      end

      def subscribe_to(event_name, proc)
        procs[event_name] = proc
      end

      # TODO: Publisher Confirms
      # TODO: Channel Level Errors
      def publish(event, message, single_message = true)
        exchange.publish(Basquiat::Adapters::Base.json_encode(message), routing_key: event)
        disconnect if single_message
      end

      # TODO: Manual ACK and Requeue
      # TODO: JSON messages
      def listen(lock = true)
        procs.keys.each { |key| bind_queue(key) }
        queue.subscribe(block: lock) do |di, _, msg|
          message = Basquiat::Adapters::Base.json_decode(msg)
          procs[di.routing_key].call(message)
        end
      end

      private

      def bind_queue(event_name)
        queue.bind(exchange, routing_key: event_name)
      end

      def connect
        connection.start
        # rescue Bunny::TCPConnectionFailed => error; Try to connect to another server or fail
      end

      def disconnect
        connection.close_all_channels
        connection.close
        @channel, @exchange = nil, nil
      end

      def connection
        @connection ||= Bunny.new(options[:server])
      end

      def channel
        connect
        @channel ||= connection.create_channel
      end

      def queue
        @queue ||= channel.queue(options[:queue][:name], options[:queue][:options])
      end

      def exchange
        @exchange ||= channel.topic(options[:exchange][:name], options[:exchange][:options])
      end
    end
  end
end
