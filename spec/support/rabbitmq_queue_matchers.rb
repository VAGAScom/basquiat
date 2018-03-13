# frozen_string_literal: true
require 'uri'
require 'net/http'

class QueueStats
  def initialize(queue)
    @queue = queue
    host   = ENV.fetch('BASQUIAT_RABBITMQ_1_PORT_15672_TCP_ADDR', 'localhost')
    port   = ENV.fetch('BASQUIAT_RABBITMQ_1_PORT_15672_TCP_PORT', 15_672)
    @uri   = URI.parse("http://#{host}:#{port}/api/queues/%2f/#{@queue}")
  end

  def unacked_messages
    queue_status.fetch(:messages_unacknowledged) { 0 }
  end

  private

  def queue_status
    @message ||= MultiJson.load(fetch, symbolize_keys: true)
  end

  def fetch
    req = Net::HTTP::Get.new @uri
    req.basic_auth('guest', 'guest')
    p res = Net::HTTP.start(@uri.host, @uri.port) { |http| http.request(req) }
    res.body
  end
end

RSpec::Matchers.define :have_n_unacked_messages do |expected| # number of unacked messages
  match do |queue| # queue
    expected == QueueStats.new(queue.name).unacked_messages
  end

  failure_message do |queue|
    "expected #{expected} unacked messages but got #{QueueStats.new(queue.name).unacked_messages}"
  end
end

RSpec::Matchers.define :have_unacked_messages do
  match do |queue|
    QueueStats.new(queue.name).unacked_messages.positive?
  end

  failure_message_when_negated do |queue|
    "expected #{queue.name} to have 0 unacked messages but got #{QueueStats.new(queue.name).unacked_messages}"
  end
end

# convenience method
def remove_queues_and_exchanges(adapter)
  # Ugly as hell. Probably transform into a proper method in session
  adapter.session.channel.queues.each_pair { |_, queue| queue.delete }
  adapter.session.channel.exchanges.each_pair { |_, ex| ex.delete }
rescue Bunny::TCPConnectionFailed
  true
ensure
  adapter.reset_connection
end
