class SimpleClient
  extend Basquiat::Base

  self.event_adapter = Basquiat::Adapters::Test
  event_source host: 'localhost', port: 5672

  #subscribe 'some.event', with: ->(msg) { puts msg }
end

# SimpleClient.listen
