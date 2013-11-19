shared_examples_for 'a Basquiat::Adapter' do
  it '#adapter_options(opts)' do
    expect(subject).to respond_to(:adapter_options)
  end

  it '#default_options [template for option initialization]' do
    expect(subject).to respond_to(:default_options)
  end

  it 'merges the options with the default ones' do
    opts = subject.instance_variable_get(:@options)
    subject.adapter_options(nice_option: '127.0.0.2')
    expect(opts[:nice_option]).to eq('127.0.0.2')
  end
end
