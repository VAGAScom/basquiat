# frozen_string_literal: true
module Basquiat
  class Railtie < ::Rails::Railtie
    initializer 'load_basquiat_configuration' do
      ENV['BASQUIAT_ENV'] = Rails.env
      Basquiat.configure do |config|
        config.config_file = Rails.root + 'config/basquiat.yml'
      end
    end

    config.after_initialize do
      Basquiat.configuration.reload_classes
    end
  end
end
