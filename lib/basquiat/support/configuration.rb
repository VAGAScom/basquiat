module Basquiat
  class Configuration
    attr_writer :queue_name, :exchange_name, :logger, :environment

    def queue_name
      @queue_name || 'vagas.queue'
    end

    def exchange_name
      @exchange_name || 'vagas.exchange'
    end

    def logger
      @logger || DefaultLogger.new
    end

    def environment
      @environment || ENV['BASQUIAT_ENV'] || 'development'
    end

    def config_file=(path)
      load_yaml(path)
      setup_basic_options
    end

    def adapter_options
      config.fetch('adapter_options') { Hash.new }
    end

    def default_adapter
      config.fetch('default_adapter') { nil }
    end

    def reload_classes
      Basquiat::Base.descendants.each do |klass|
        klass.clear_adapter
      end
    end

    private
    def config
      @yaml.fetch(environment)
    end

    def load_yaml(path)
      yaml_data = File.readlines(path).join
      @yaml     = YAML.load(yaml_data)
    end

    def setup_basic_options
      @queue_name    ||= config.fetch('queue_name')
      @exchange_name ||= config.fetch('exchange_name')
    end
  end
end
