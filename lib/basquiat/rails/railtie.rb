module Basquiat
  class Railtie < ::Rails::Railtie
    initializer 'load_basquiat_configuration' do
      Basquiat.configure do |config|
        config.config_file = Rails.root + 'config/basquiat.yml'
        config.reload_classes
      end
    end
  end
end
