module Basquiat
  module Adapters
    class RabbitMq
      class Session
        attr_reader :channel

        def initialize(channel, session_options = {})
          @channel = channel
          @options = session_options
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

        def subscribe(lock)
          queue.subscribe(block: lock, manual_ack: true) do |di, props, msg|
            yield Basquiat::Adapters::RabbitMq::Message.new(msg, di, props)
          end
        end

        def queue
          @queue ||= channel.queue(@options[:queue][:name],
                                   durable:   true,
                                   arguments: (@options[:queue][:options] || {}))
        end

        def exchange
          @exchange ||= channel.topic(@options[:exchange][:name],
                                      durable:   true,
                                      arguments: (@options[:exchange][:options] || {}))
        end
      end
    end
  end
end
