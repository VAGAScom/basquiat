# frozen_string_literal: true
require 'basquiat/adapters/rabbitmq/requeue_strategies/base_strategy'
require 'basquiat/adapters/rabbitmq/requeue_strategies/auto_acknowledge'
require 'basquiat/adapters/rabbitmq/requeue_strategies/basic_acknowledge'
require 'basquiat/adapters/rabbitmq/requeue_strategies/dead_lettering'
require 'basquiat/adapters/rabbitmq/requeue_strategies/delayed_delivery'

Basquiat::Adapters::RabbitMq.register_strategy(:auto_ack, Basquiat::Adapters::RabbitMq::AutoAcknowledge)
Basquiat::Adapters::RabbitMq.register_strategy(:basic_ack, Basquiat::Adapters::RabbitMq::BasicAcknowledge)
Basquiat::Adapters::RabbitMq.register_strategy(:dead_lettering, Basquiat::Adapters::RabbitMq::DeadLettering)
Basquiat::Adapters::RabbitMq.register_strategy(:delayed_delivery, Basquiat::Adapters::RabbitMq::DelayedDelivery)
