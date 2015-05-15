module Basquiat
  module Adapters
    class RabbitMq
      class DeadLettering < BaseStrategy
        def initialize(session)
          super
          setup_dead_lettering
        end

        def self.session_options
          { queue: { options: { 'x-dead-letter-exchange' => 'basquiat.dlx' } }, exchange: {} }
        end

        def run(message)
          catch :skip_processing do
            check_incoming_messages(message)
            yield
          end
          public_send(message.action, message.delivery_tag)
        end

        private

        def check_incoming_messages(message)
          redelivered = message.delivery_info.redelivered

          redelivered and
              message.props.headers['x-death'][1]['queue'] != session.queue.name and
              throw :skip_processing
        end

        def setup_dead_lettering
          dlx   = @session.channel.topic('basquiat.dlx')
          queue = @session.channel.queue('basquiat.dlq',
                                         ttl:       1_000 * 5,
                                         arguments: { 'x-dead-letter-exchange' => @session.exchange.name,
                                                      'x-message-ttl'          => 1_000 })
          queue.bind(dlx, routing_key: '*.#')
        end
      end
    end
  end
end
