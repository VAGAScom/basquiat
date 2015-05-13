module Basquiat
  module Adapters
    class RabbitMq
      class DeadLettering < BaseStrategy
        def initialize(session)
          super
          setup_dead_lettering
        end

        def self.session_options
          { queue: { dead_letter_exchange: 'basquiat.dlx' } }
        end

        def run(message)
          catch :skip_processing do
            check_incoming_message
            yield
            send(message.di.delivery_tag, message.action)
          end
        end

        private

        def check_incoming_messages
        end

        def setup_dead_lettering
          dlx = @session.channel.topic('basquiat.dlx')
          queue = @session.channel.queue('basquiat.dlq', ttl: 5 * 60 * 1000, dead_letter_exchange: @session.exchange.name)
          queue.bind(dlx, routing_key: '#')
        end
      end
    end
  end
end
