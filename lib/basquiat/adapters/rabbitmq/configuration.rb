module Basquiat
  module Adapters
    class RabbitMq
      class Configuration
        using Basquiat::HashRefinements

        def initialize
          @options = { connection:
                                  { hosts: ['localhost'],
                                    port:  5672,
                                    auth:  { user: 'guest', password: 'guest' }
                                  },
                       queue:     {
                         name:    Basquiat.configuration.queue_name,
                         options: { durable: true } },
                       exchange:  {
                         name:    Basquiat.configuration.exchange_name,
                         options: { durable: true } },
                       publisher: { confirm: true, persistent: false },
                       requeue:   { enabled: false } }
        end

        def base_options
          @options
        end

        def merge_user_options(user_opts)
          @options.merge!(user_opts)
        end

        def connection_options
          @options[:connection]
        end

        def session_options
          { exchange:  @options[:exchange],
            publisher: @options[:publisher],
            queue:     @options[:queue] }.deep_merge(strategy.session_options)
        end

        def strategy
          requeue = @options[:requeue]
          return BasicAcknowledge unless requeue[:enabled]
          @strategy ||= RabbitMq.strategy(requeue[:strategy].to_sym)
          @strategy.setup(requeue[:options] || {})
          @strategy
        end
      end
    end
  end
end
