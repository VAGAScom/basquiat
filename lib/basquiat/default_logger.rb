require 'logger'

Basquiat::DefaultLogger = Naught.build { |builder| builder.mimic Logger }
