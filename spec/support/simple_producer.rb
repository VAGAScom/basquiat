class DummyProducer < Basquiat::Producer
  self.event_adapter = Basquiat::Adapters::TestAdapter
  self.event_source host: 'localhost', port: 5672
end

#DummyProducer.publish('vagas.mensagem.bem_vindo', candidato_id: 12345)
