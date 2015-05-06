require 'spec_helper'

# Sample class used for testing
class SampleAdapter < Basquiat::Adapters::Base
end

describe Basquiat::Adapters::Base do
  subject { SampleAdapter.new }
  it_behaves_like 'a Basquiat::Adapter'

  [:disconnect, :subscribe_to, :publish].each do |meth|
    it "raise a SubclassResponsibility error if #{meth} isn't implemented" do
      expect { subject.public_send(meth) }.to raise_error Basquiat::Errors::SubclassResponsibility
    end
  end
end
