require 'logger'

module Basquiat
  DefaultLogger = Naught.build { |builder| builder.mimic Logger }
end
