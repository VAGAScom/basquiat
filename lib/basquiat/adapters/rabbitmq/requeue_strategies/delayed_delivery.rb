module Basquiat
  module Adapters
    class RabbitMq
      module Strategies
        class DelayedDeliveryWIP
          def initialize(channel, message)
            @channel = channel
            @message = message
          end

          # Criar um exchange
          # Criar o queue (ou redeclara-lo)
          # O queue tem que ter um dlx para o exchange padrão
          # Publicar a mensagem no exchange com um ttl igual ao anterior **2
          # dar um unack caso o tempo estoure o maximo.
          def message_handler
            delay    = message[:headers][0][:expiration]**2
            exchange = channel.topic('basquiat.dd')
            queue    = channel.queue('delay', ttl: delay * 2)
            queue.bind(exchange, 'original_queue.delay.message_name')
            exchange.publish('original_queue.delay.message_name', message, ttl: delay, dlx: default_exchange)
          end
        end
      end
    end
  end
end
