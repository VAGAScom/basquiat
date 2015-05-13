shared_examples_for 'a Basquiat::Adapter' do

  after(:each) do
    adapter.class::STRATEGIES.clear
  end

  [:adapter_options,
   :base_options,
   :default_options,
   :publish,
   :subscribe_to,
   :disconnect].each do |meth|
    it "#{meth}" do
      expect(adapter).to respond_to(:adapter_options)
    end
  end


end
