require 'spec_helper'
require_relative '../../../spec/support/basquiat_base_shared_examples'

class SampleClass
  include Basquiat::Base
  self.event_adapter = Basquiat::Adapters::Test
end

describe Basquiat::Base do
  subject { SampleClass }
  it_behaves_like 'Basquiat::Base'
end
