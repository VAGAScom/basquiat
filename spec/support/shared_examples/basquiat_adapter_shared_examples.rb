shared_examples_for 'a Basquiat::Adapter' do
  [:adapter_options,
   :base_options,
   :default_options,
   :publish,
   :subscribe_to,
   :disconnect].each do |meth|
    it "#{meth}" do
      expect(subject).to respond_to(:adapter_options)
    end
  end

  it 'merges the options with the default ones' do
    opts = subject.instance_variable_get(:@options)
    subject.adapter_options(nice_option: '127.0.0.2')
    expect(opts[:nice_option]).to eq('127.0.0.2')
  end
end
