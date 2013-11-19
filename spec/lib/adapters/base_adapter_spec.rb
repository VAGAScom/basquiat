require 'spec_helper'

class SampleAdapter
  include Basquiat::Adapters::Base
end

describe Basquiat::Adapters::Base do
  subject { SampleAdapter.new }
  it_behaves_like 'a Basquiat::Adapter'
end
