# frozen_string_literal: true

shared_examples_for 'a Basquiat::Adapter' do
  %i(adapter_options
     base_options
     default_options
     publish
     subscribe_to
     disconnect).each do |meth|
    it meth.to_s do
      expect(adapter).to respond_to(:meth)
    end
  end
end
