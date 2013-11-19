shared_examples 'Basquiat::Base' do
  it '.event_adapter' do
    expect(subject).to respond_to(:event_adapter=)
  end

  it '.event_source(option_hash)' do
    expect(subject).to respond_to(:event_source)
  end

  it 'set the adapter options to host: localhost and port: 5672' do
    subject.adapter.should_receive(:adapter_options).with(host: 'coisa')
    subject.event_source :host => 'coisa'
  end
end
