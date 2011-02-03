# encoding: utf-8

require "rubygems"

require 'bundler'
Bundler.setup
Bundler.require :default, :test

gem "amqp"
require "mq"

module AMQP
  Channel = ::MQ
end


#
# Ruby version-specific
#

case RUBY_VERSION
when "1.8.7" then
  module ArrayExtensions
    def sample
      self.choice
    end # sample
  end

  class Array
    include ArrayExtensions
  end
when "1.8.6" then
  raise "Ruby 1.8.6 is not supported. Sorry, pal. Time to move on beyond One True Ruby. Yes, time flies by."
when /^1.9/ then
  puts "Encoding.default_internal was #{Encoding.default_internal || 'not set'}, switching to UTF8"
  Encoding.default_internal = Encoding::UTF_8
  
  puts "Encoding.default_external was #{Encoding.default_internal || 'not set'}, switching to UTF8"
  Encoding.default_external = Encoding::UTF_8  
end




#
# AMQP broker connection
#

amqp_config = File.dirname(__FILE__) + '/amqp.yml'

if File.exists?(amqp_config)
  class Hash
    def symbolize_keys
      self.inject({}) do |result, (key, value)|
        new_key         = key.is_a?(String) ? key.to_sym : key
        new_value       = value.is_a?(Hash) ? value.symbolize_keys : value
        result[new_key] = new_value

        result
      end
    end # def
  end # class

  AMQP_OPTS = YAML::load_file(amqp_config).symbolize_keys[:test]
else
  AMQP_OPTS = { :host => 'localhost', :port => 5672 }
end
