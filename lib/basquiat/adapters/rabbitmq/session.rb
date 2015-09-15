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
                             persistent:  true,
                             timestamp:   Time.now.to_i }.merge(props))
        end

        def subscribe(lock)
          channel.prefetch(@options[:consumer][:prefetch])
          queue.subscribe(block: lock, manual_ack: true) do |di, props, msg|
            yield Basquiat::Adapters::RabbitMq::Message.new(msg, di, props)
          end
        end

        def queue
          @queue ||= channel.queue(@options[:queue][:name],
                                   durable:   @options[:queue][:durable],
                                   arguments: (@options[:queue][:options] || {}))
        end

        def exchange
          @exchange ||= channel.topic(@options[:exchange][:name],
                                      durable:   @options[:exchange][:durable],
                                      arguments: (@options[:exchange][:options] || {}))
        end
      end
    end
  end
end
