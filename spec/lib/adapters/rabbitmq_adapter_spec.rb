require 'spec_helper'
require_relative '../../../lib/adapters/rabbitmq_adapter'

describe Basquiat::Adapters::RabbitMq do
  subject { Basquiat::Adapters::RabbitMq.new }
  it_behaves_like 'a Basquiat::Adapter'
end
