#!/usr/bin/env ruby

require 'bundler'
Bundler.setup


require "bunny"
require "json"
require "active_support/core_ext/hash"

class CommandHandler
  class << self
    attr_accessor :connection
  end

  def self.exchange_declare(delivery_info, properties, payload)
    opts = payload.symbolize_keys

    self.connection.with_channel do |ch|
      puts "[exchange.declare] Declaring #{properties.headers['name']} of type #{opts[:type]}, durable: #{opts[:durable]}, auto-delete: #{opts[:'auto-delete']}"
      ch.__send__(opts[:type], properties.headers["name"], :durable => opts[:durable], :auto_delete => opts[:'auto-delete'])
    end
  end

  def self.queue_declare(delivery_info, properties, payload)
    opts = payload.symbolize_keys
    self.connection.with_channel do |ch|
      puts "[queue.declare] Declaring #{properties.headers['name']}, durable: #{opts[:durable]}, auto-delete: #{opts[:'auto-delete']}"
      ch.queue(properties.headers["name"], :durable => opts[:durable], :auto_delete => opts[:'auto-delete'])
    end
  end

  def self.handle_command(cmd, delivery_info, properties, payload)
    case cmd
    when "exchange.declare" then
      exchange_declare(delivery_info, properties, payload)
    when "queue.declare" then
      queue_declare(delivery_info, properties, payload)
    when "queue.bind" then
      queue_bind(delivery_info, properties, payload)
    end
  end
end


conn = Bunny.new(:host => "127.0.0.1")
conn.start

CommandHandler.connection = conn

puts "Connected to RabbitMQ. Running #{Bunny::VERSION} version of Bunny..."

ch   = conn.create_channel
q    = ch.queue("commands.bunny", :auto_delete => true)

q.subscribe(:block => true) do |delivery_info, properties, payload|
  puts "Handling a command: #{properties.type}..."

  CommandHandler.handle_command(properties.type, delivery_info, properties, JSON.load(payload))
end
