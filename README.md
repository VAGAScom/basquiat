# Basquiat

[![Issue Count](https://codeclimate.com/github/VAGAScom/basquiat/badges/issue_count.svg)](https://codeclimate.com/github/VAGAScom/basquiat)
[![Test Coverage](https://codeclimate.com/github/VAGAScom/basquiat/badges/coverage.svg)](https://codeclimate.com/github/VAGAScom/basquiat/coverage)

**Basquiat** is library aimed to hide (almost) all the complexity when working with some kind of message queue from the application internals.

All the exchanges, connections, queues and sessions declarations are swept under rug. The aim is to provide a simple yet flexible interface to work with message queues.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'basquiat'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install basquiat
```

You will also need the right gem for your Message Queue (MQ) system. Bundled in this gem you will find 1 adapter, for RabbitMQ, which depends on the gem _bunny_.

## Basic Usage

First of all require the gem, the dependency for the adapter and the adapter itself

```ruby
require 'basquiat'
require 'bunny'
require 'basquiat/adapters/rabbitmq_adapter'
```

Then you can extend the class that you will use for communicating with the MQ, setting the adapter:

```ruby
class TownCrier
  extend Basquiat::Base
  self.event_adapter Basquiat::Adapters::RabbitMq
end
```
From there you can publish events to the queue

```ruby
TownCrier.publish('some.nifty.event', {a: 'hash', of: 'values'})
```
And you can subscribe to one or more events using a proc that will get called when the message is received:

```ruby
class TownCrier
  extend Basquiat::Base

  subscribe_to 'some.nifty.event', ->(msg) { msg.fetch(:of, '').upcase }
end
```

## Configuration

You can setup Basquiat using the configure method. This method will yield a Configuration object:

```ruby
Basquiat.configure do |config|
  config.exchange_name = 'my_exchange'
end
```
The available options are:

- config_file= Receive a path to an YAML file (example here)
- connection= Makes Basquiat to use a provided Bunny connection
- queue_name= The default queue name
- exchange_name= The default exchange name
- environment= Forces the environment to something other than the value of BASQUIAT_ENV
- logger= The logger to be used. Defaults to a null object logger.

The configuration can be reset using the `Basquiat.reset` method.

YAML File configuration example:

```yaml
test:                                       #environment
  default_adapter: Basquiat::Adapters::Test #it will overwrite the adapter on all classes that extend Basquiat::Base
  adapter_options:                          #Adapter specific options
    servers:
      -
        host: 'localhost'
        port: '98765'
development:                                #full example of the RabbitMq options
  exchange_name: 'basquiat.exchange'
  queue_name: 'basquiat.queue'
  default_adapter: Basquiat::Adapters::RabbitMq
  adapter_options:
    connection:
      hosts:
        - 'localhost'
      port: 5672
      vhost: '/'
      auth:
        user: 'guest'
        password: 'guest'
      tls_options:
        tls: false
    publisher:
      confirm: true
      persistent: true
      session_pool:
        size: 10
        timeout: 5
    requeue:
      enabled: true
      strategy: delayed_delivery
      options:
        retries: 10
        queue_name_preffix: wait.for_it
        exchange_name: legendary
```
