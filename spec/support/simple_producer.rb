class DummyProducer < Basquiat::Producer
  event_adapter Basquiat::Adapters::NullAdapter
  #event_producer host: 'localhost', port: 5672
end

#DummyProducer.publish('vagas.mensagem.bem_vindo', candidato_id: 12345)
