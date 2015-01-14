require 'bunny'
require 'basquiat'
require 'basquiat/adapters/rabbitmq_adapter'

class SomeWorker
  extend Basquiat::Base

  self.event_adapter = Basquiat::Adapters::RabbitMq

  subscribe_to 'some.event', ->(msg) { puts msg }
  subscribe_to 'another.event', ->(msg) { puts msg.class }
end

SomeWorker.listen
