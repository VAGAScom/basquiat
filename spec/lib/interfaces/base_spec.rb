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
end
