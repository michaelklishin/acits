#!/usr/bin/env ruby

require 'bundler'
Bundler.setup


require "amqp"
require "json"
require "active_support/core_ext/hash"

class CommandHandler
  def self.exchange_declare(metadata, payload)
    opts = payload.symbolize_keys

    ch = AMQP::Channel.new
    puts "[exchange.declare] Declaring #{metadata.headers['name']} of type #{opts[:type]}, durable: #{opts[:durable]}, auto-delete: #{opts[:'auto-delete']}"
    ch.__send__(opts[:type], metadata.headers["name"], :durable => opts[:durable], :auto_delete => opts[:'auto-delete'])
  end


  def self.queue_declare(metadata, payload)
    opts = payload.symbolize_keys

    ch = AMQP::Channel.new
    puts "[queue.declare] Declaring #{metadata.headers['name']}, durable: #{opts[:durable]}, auto-delete: #{opts[:'auto-delete']}"
    ch.queue(metadata.headers["name"], :durable => opts[:durable], :auto_delete => opts[:'auto-delete'])
  end


  def self.queue_bind(delivery_info, properties, payload)
    opts = payload.symbolize_keys

    self.connection.with_channel do |ch|
      puts "[queue.bind] Binding #{properties.headers['queue']} to #{properties.headers['exchange']} with routing key #{properties.headers['routing_key']}"
      ch.queue(properties.headers['queue'], :auto_delete => true).bind(properties.headers['exchange'], :routing_key => opts[:routing_key])
    end
  end


  def self.handle_command(cmd, metadata, payload)
    case cmd
    when "exchange.declare" then
      exchange_declare(metadata, payload)
    when "queue.declare" then
      queue_declare(metadata, payload)
    when "queue.bind" then
      queue_bind(metadata, payload)
    end
  end
end

EventMachine.run do
  connection = AMQP.connect(:host => '127.0.0.1')
  puts "Connected to AMQP broker. Running #{AMQP::VERSION} version of the gem..."

  channel  = AMQP::Channel.new(connection)
  queue    = channel.queue("commands.amqp-gem", :auto_delete => true)

  queue.subscribe do |metadata, payload|
    puts "Handling a command: #{metadata.type}..."

    CommandHandler.handle_command(metadata.type, metadata, JSON.load(payload))
  end
end
