module Basquiat
  module Adapters
    class RabbitMq
      class DelayedDelivery < BaseStrategy
        class << self
          attr_reader :options

          def setup(opts)
            @options = { ddl: { retries: opts.fetch(:retries, 5) } }
          end
        end

        def initialize(session)
          super(session)
          setup_delayed_delivery
        end

        def run(message)
          message.routing_key = clear_routing_key(message.routing_key)
          yield
          public_send(message.action, message)
        end

        def requeue(message)
          @exchange.publish(Basquiat::Json.encode(message), routing_key: routing_key_for(message.di.routing_key))
          ack(message)
        end

        private
        def routing_key_for(key)
          md = key.match(/^(\d+)\.(#{@session.queue.name})\.(.+)$/)
          if md
            "#{ 2 * (md.captures[0].to_i) }.#{md.captures[1]}.#{md.captures[2]}"
          else
            "1000.#{@session.queue.name}.#{key}"
          end
        end

        def clear_routing_key(key)
          md = key.match(/^\d+\.#{@session.queue.name}\.(.+)$/)
          md and md.captures[0]
        end

        def options
          self.class.options[:ddl]
        end

        def setup_delayed_delivery
          @exchange = @session.channel.topic('basquiat.dlx', durable: true)
          @session.bind_queue("*.#{@session.queue.name}.#")
          options[:retries].times do |iteration|
            timeout = 2 ** iteration
            queue   = @session.channel.queue("basquiat.ddlq_#{timeout}", durable: true,
                                             arguments:                           {
                                                 'x-dead-letter-exchange' => @session.exchange.name,
                                                 'x-message-ttl'          => timeout * 1_000 })
            queue.bind(@exchange, routing_key: "#{timeout * 1_000}.#")
          end
        end
      end
    end
  end
end
