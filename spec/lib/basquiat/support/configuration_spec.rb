# frozen_string_literal: true

# RSpec.describe Basquiat::Configuration do
#   subject(:config) { Basquiat::Configuration.new }

#   it '#config_file=' do
#     config.config_file = File.join(File.dirname(__FILE__), '../../../support/basquiat.yml')

#     expect(config.queue_name).to eq('my.nice_queue')
#     expect(config.exchange_name).to eq('my.test_exchange')
#     expect(config.default_adapter).to eq('Basquiat::Adapters::Test')
#     expect(config.adapter_options).to have_key(:servers)
#   end

#   it 'settings provided on the config file have lower precedence' do
#     config.exchange_name = 'super.nice_exchange'
#     config.config_file   = File.join(File.dirname(__FILE__), '../../../support/basquiat.yml')

#     expect(config.exchange_name).to eq('super.nice_exchange')
#   end
# end
