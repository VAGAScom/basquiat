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

You will also need the right gem for your Message Queue (MQ) system. Bundled in this gem you will find 1 adapter, for RabbitMQ, which depends on the gem `bunny`.

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
  self.adapter = Basquiat::Adapters::RabbitMq
end
```
From there you can publish events to the queue (the _RabbitMq Adapter_ uses [topic exchanges](http://www.rabbitmq.com/tutorials/tutorial-five-ruby.html) by default).

```ruby
TownCrier.publish('event.name', {a: 'hash', of: 'values'})
```
And you can subscribe to one or more events using a proc that will get called when the message is received:

```ruby
class TownCrier
  extend Basquiat::Base

  subscribe_to 'event.name', ->(msg) { msg.fetch(:of, '').upcase }
end
```

## Configuration

You can setup Basquiat as bellow:

```ruby
# using a block
Basquiat.configure do |config|
  config.exchange_name = 'my_exchange'
end

# or setting each value by itself
Basquiat.configuration.logger = UberLogger.new(destination: '/dev/null')
```
The available options are:

- `config_file=` Receive a path to an YAML file (example here)
- `queue_name=` The default queue name
- `exchange_name=` The default exchange name
- `environment=` Forces the environment to something other than the value of `BASQUIAT_ENV`
- `logger=` The logger to be used. Defaults to a null object logger.

The configuration can be reset using the `Basquiat.reset` method.

You can instead use an YAML file to setup the library using the `Basquiat.config_file=` method:

```ruby
Basquiat.config_file = 'path/to/yaml' # => Absolute or relative to project root
```

An example configuration file is provided below:

```yaml
test: # environment name
  default_adapter: Basquiat::Adapters::Test # adapter to be used when none are provided
  exchange_name: basquiat.exchange # default exchange name
  queue_name: basquiat.queue # default queue name
development:
  default_adapter: Basquiat::Adapters::RabbitMq
```

