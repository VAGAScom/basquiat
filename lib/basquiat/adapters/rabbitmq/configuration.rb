module Basquiat
  module Adapters
    class RabbitMq
      class Configuration
        using Basquiat::HashRefinements

        def initialize
          @options = { failover:  { default_timeout: 5, max_retries: 5 },
                       servers:   [{ host: 'localhost', port: 5672 }],
                       queue:     {
                           name:    Basquiat.configuration.queue_name,
                           options: { durable: true } },
                       exchange:  {
                           name:    Basquiat.configuration.exchange_name,
                           options: { durable: true } },
                       publisher: { confirm: true, persistent: false },
                       auth:      { user: 'guest', password: 'guest' },
                       requeue:   { enabled: false } }
        end

        def base_options
          @options
        end

        def merge_user_options(user_opts)
          @options.merge!(user_opts)
        end

        def connection_options
          { servers:  @options[:servers],
            failover: @options[:failover],
            auth:     @options[:auth] }
        end

        def session_options
          { exchange:  @options[:exchange],
            publisher: @options[:publisher],
            queue:     @options[:queue] }.deep_merge(strategy.session_options)
        end

        def strategy
          return BasicAcknowledge unless @options[:requeue][:enabled]
          @strategy ||= RabbitMq.strategies.fetch(@options[:requeue][:strategy].to_sym)
          @strategy.setup(@options[:requeue][:options] || {})
          @strategy
        rescue KeyError
          fail Basquiat::Errors::StrategyNotRegistered.new(@options[:requeue][:strategy])
        end
      end
    end
  end
end
