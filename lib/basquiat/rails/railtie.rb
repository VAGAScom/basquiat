module Basquiat
  class Railtie < ::Rails::Railtie
    initializer 'load_basquiat_configuration' do
      Basquiat.configure do |config|
        config.config_file = Rails.root + 'config/basquiat.yml'
        ENV['BASQUIAT_ENV'] = Rails.env
      end
    end

    config.after_initialize do
      Basquiat.configuration.reload_classes
    end
  end
end
