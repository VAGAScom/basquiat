module Basquiat
  module Json
    def self.encode(object)
      MultiJson.dump(object)
    end

    def self.decode(object)
      MultiJson.load(object, symbolize_keys: true)
    rescue MultiJson::ParseError
      {}
    end
  end
end
