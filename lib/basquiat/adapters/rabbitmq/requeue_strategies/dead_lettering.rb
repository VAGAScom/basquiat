module Basquiat
  module Adapters
    class RabbitMq
      class DeadLettering < BaseStrategy
        class << self
          attr_reader :options

          def setup(opts)
            @options = { session:
                              { queue:
                                    { options:
                                          { 'x-dead-letter-exchange' => opts.fetch(:exchange, 'basquiat.dlx') } } },
                         dlx: { ttl: opts.fetch(:ttl, 1_000) } }
          end

          def session_options
            options.fetch :session
          rescue KeyError
            raise 'You have to setup the strategy first'
          end
        end

        def initialize(session)
          super
          setup_dead_lettering
        end

        def run(message)
          catch :skip_processing do
            check_incoming_messages(message.props.headers)
            yield
          end
          public_send(message.action, message)
        end

        private

        def check_incoming_messages(headers)
          headers and
              headers['x-death'][1]['queue'] != @session.queue.name and
              throw(:skip_processing)
        end

        def options
          self.class.options
        end

        def setup_dead_lettering
          dlx   = @session.channel.topic('basquiat.dlx')
          queue = @session.channel.queue('basquiat.dlq',
                                         arguments: { 'x-dead-letter-exchange' => @session.exchange.name,
                                                      'x-message-ttl'          => options[:dlx][:ttl] })
          queue.bind(dlx, routing_key: '#')
        end
      end
    end
  end
end
