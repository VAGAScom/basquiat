# Basquiat

**Basquiat** is intended to hide (almost) all the complexity of working with some kind of message queue from the application internals.

All the exchanges, connections, queues and sessions declarations are swept under rug. The main aim is to provide a simple yet flexible interface to work with message queues.

## Installation

Add this line to your application's Gemfile:

    gem 'basquiat'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install basquiat

You will also need the right gem for your MQ system. Bundled in this gem you will find 2 adapters for RabbitMQ and ActiveMQ which depends on the gems _bunny_ and _ruby-stomp_ respectively.

## Basic Usage

First of all require the gem, the dependecy for the adapter and the adapter itself

    require 'basquiat'
    require 'bunny'
    require 'basquiat/adapters/rabbitmq_adapter'

Then you can extend the class that you will use for communicating with the MQ

    class TownCrier
      extend Basquiat::Base
    end

From here you can publish events to the queue

    TownCrier.publish('some.nifty.event', {a: 'hash', of: 'values'})

And you can subscribe to one or more events using a proc that will get called when the message is received:

    class TownCrier
      extend Basquiat::Base

      subscribe_to 'some.nifty.event', ->(msg) { msg.fetch(:of, '').upcase }
    end

## Configuration

You can setup Basquiat using the configure method. This method will yield a Configuration object:

    Basquiat.configure do |config|
      config.exchange_name = 'my_exchange'
    end

The available options are:

- config_file= Receive a path to an YAML file (example here)
- queue_name= The default queue name
- exchange_name= The default exchange name
- environment= Forces the environment to something other than the value of BASQUIAT_ENV
- logger= The logger to be used. Defaults to a null logger.

The configuration can be reset using the Basquiat.reset method.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
