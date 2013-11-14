require 'bunny'
class DummyProducer
  def initialize
    @mq = event_producer
  end

  def publish(message, routing_key)
    @mq.publish(message, routing_key: routing_key)
  end

  private
  def event_producer
    # tratamento de erro se faz necessario
    conn = ::Bunny.new
    conn.start
    channel = conn.create_channel
    channel.topic(Basquiat::Configuration.exchange_name, durable: true)
  end
end

DummyProducer.new.publish('Bem Vindo a Vagas', 'vagas.mensagem.bem_vindo')
