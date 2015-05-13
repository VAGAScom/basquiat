module Basquiat
  module Adapters
    class RabbitMq
      class Session
        def initialize(connection, session_options = {})
          @connection = connection
          @options    = session_options
        end

        def bind_queue(routing_key)
          queue.bind(exchange, routing_key: routing_key)
        end

        def publish(routing_key, message, props = {})
          channel.confirm_select if @options[:publisher][:confirm]
          exchange.publish(Basquiat::Json.encode(message),
                           { routing_key: routing_key,
                             timestamp:   Time.now.to_i }.merge(props))
        end

        def subscribe(lock, &_block)
          queue.subscribe(block: lock, manual_ack: true) do |di, props, msg|
            message = Basquiat::Adapters::RabbitMq::Message.new(msg, di, props)
            yield di.routing_key, message
          end
        end

        def channel
          @connection.start unless @connection.connected?
          @channel ||= @connection.create_channel
        end

        def queue
          @queue ||= channel.queue(@options[:queue][:name], arguments: (@options[:queue][:options]||{}))
        end

        def exchange
          @exchange ||= channel.topic(@options[:exchange][:name], arguments: (@options[:exchange][:options]|| {}))
        end
      end
    end
  end
end
