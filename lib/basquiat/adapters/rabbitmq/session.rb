module Basquiat
  module Adapters
    class RabbitMq
      class Session
        ACK_STRATEGIES = {
            ack:   -> { channel.ack(message.di.delivery_tag, false) },
            unack: -> { channel.unack(message.di.delivery_tag, false) },
        }

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

        def subscribe(block)
          queue.subscribe(block: block, manual_ack: true) do |di, props, msg|
            message = Basquiat::Adapters::RabbitMq::Message.new(msg, di, props)
            yield di.routing_key, message
            ACK_STRATEGIES[message.action].call
          end
        end

        def channel
          @connection.start unless @connection.connected?
          @channel ||= @connection.create_channel
        end

        def queue
          @queue ||= channel.queue(@options[:queue][:name], @options[:queue][:options])
        end

        def exchange
          @exchange ||= channel.topic(@options[:exchange][:name], @options[:exchange][:options])
        end
      end
    end
  end
end
