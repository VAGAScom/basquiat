require 'spec_helper'

class SampleClass
  include Basquiat::Base
end

describe Basquiat::Base do
  it '.event_adapter' do
    expect(SampleClass).to respond_to(:event_adapter=)
  end

  it '.event_source(option_hash)' do
    expect(SampleClass).to respond_to(:event_source)
  end

  it 'set the adapter options to host: localhost and port: 5672' do
    Basquiat::Adapters::Test.any_instance.should_receive(:adapter_options).with(host: 'coisa')
    SampleClass.event_adapter = Basquiat::Adapters::Test
    SampleClass.event_source :host => 'coisa'
  end
end
