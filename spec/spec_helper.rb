# encoding: utf-8

Bundler.setup
Bundler.require :default, :test

require "amqp"
require "effin_utf8"

#
# Ruby version-specific
#

case RUBY_VERSION
when "1.8.7" then
  class Array
    alias sample choice
  end
when "1.8.6" then
  raise "Ruby 1.8.6 is not supported. Sorry, pal. Time to move on beyond One True Ruby. Yes, time flies by."
end




#
# AMQP broker connection
#

AMQP_OPTS = { :host => 'localhost', :port => 5672 }
