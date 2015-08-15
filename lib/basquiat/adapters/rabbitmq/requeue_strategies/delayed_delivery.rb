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
          Basquiat.logger.debug '>>>>>>>>>>>>>>>>>>>>>>>>>>>' + message.routing_key
          yield
          public_send(message.action, message)
        end

        def requeue(message)
          unack(message)
          @exchange.publish(message, routing_key: new_routing_key_for(message))
        end

        private
        def clear_routing_key(key)
          Basquiat.logger.debug '>>>>>>>>>>>>>>>>>>>>>>>>>>>' + key
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
            queue   = @session.channel.queue("basquiat.ddlq_#{timeout}",
                                             durable:   true,
                                             arguments: {
                                                 'x-dead-letter-exchange' => @session.exchange.name,
                                                 'x-message-ttl'          => timeout * 1_000 })
            queue.bind(@exchange, routing_key: "#{timeout}.#")
          end
        end
      end
    end
  end
end
