class DummyClient
  include Basquiat::Consumer
  event_adapter RabbitAdapter

  event_source host: 'localhost', port: 5672
  subscribe 'some.event', with: ->(msg) { puts msg }
end

