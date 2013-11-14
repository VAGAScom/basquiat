class DummyClient
  event_source('localhost', 5672)
  subscribe 'some.event', with: ->(msg) { puts msg }
end

