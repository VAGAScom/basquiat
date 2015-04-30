require 'bunny'
require 'delegate'
require 'basquiat/adapters/rabbitmq/message'
require 'basquiat/adapters/rabbitmq/connection'

module Basquiat
  module Adapters
    # The RabbitMQ adapter for Basquiat
    class RabbitMq
      include Basquiat::Adapters::Base

      def default_options
        { failover:  { default_timeout: 5, max_retries: 5 },
          servers:   [{ host: 'localhost', port: 5672 }],
          queue:     { name: Basquiat.configuration.queue_name, options: { durable: true } },
          exchange:  { name: Basquiat.configuration.exchange_name, options: { durable: true } },
          publisher: { confirm: true, persistent: false },
          auth:      { user: 'guest', password: 'guest' } }
      end

      def subscribe_to(event_name, proc)
        procs[event_name] = proc
      end

      def publish(event, message, persistent: options[:publisher][:persistent])
        connection.with_network_failure_handler do
          channel.confirm_select if options[:publisher][:confirm]
          exchange.publish(Basquiat::Json.encode(message), routing_key: event, timestamp: Time.now.to_i)
          reset_connection unless persistent
        end
      end

      def listen(block: true)
        connection.with_network_failure_handler do
          procs.keys.each { |key| bind_queue(key) }
          queue.subscribe(block: block, manual_ack: true) do |di, props, msg|
            message = Message.new(Basquiat::Json.decode(msg), di, props)
            procs[di.routing_key].call(message)
            if message.ack?
              channel.ack(di.delivery_tag)
            else
              channel.unack(di.delivery_tag, false)
            end
          end
        end
      end

      private

      def bind_queue(event_name)
        queue.bind(exchange, routing_key: event_name)
      end

      def reset_connection
        connection.disconnect
        @channel, @exchange, @queue = nil, nil, nil, nil
      end

      def connection
        @connection ||= Connection.new(
            servers:  options[:servers],
            failover: options[:failover],
            auth:     options[:auth])
      end

      def channel
        connection.start
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
