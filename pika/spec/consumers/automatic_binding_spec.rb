# -*- coding: utf-8 -*-
require "spec_helper"

describe "Queue that was bound to default direct exchange thanks to Automatic Mode (section 2.1.2.4 in AMQP 0.9.1 spec)" do

  #
  # Environment
  #

  include EventedSpec::AMQPSpec

  em_before { AMQP.cleanup_state }
  em_after  { AMQP.cleanup_state }

  default_options AMQP_OPTS
  default_timeout 2

  amqp_before do
    @channel   = AMQP::Channel.new
    if AMQP::VERSION.to_f >= 0.8
      @channel.should be_open
    end

    @queue     = @channel.queue("amqpgem.interoperability.queue", :auto_delete => true)
  end

  after(:all) do
    AMQP.cleanup_state
    done
  end


  #
  # Examples
  #

  it "receives messages with routing key equals it's name" do
    number_of_received_messages = 0
    expected_number_of_messages = 3

    expected_string             = "Hello World! Hablamos Español. Привет, AMQP клиент!"
    @queue.subscribe do |payload|
      number_of_received_messages += 1
      if RUBY_VERSION =~ /^1.9/
        payload.force_encoding("utf-8").should == expected_string
      else
        payload.should == expected_string
      end

      if number_of_received_messages == expected_number_of_messages
        $stdout.puts "Got all the messages I expected, wrapping up..."
      else
        n = expected_number_of_messages - number_of_received_messages
        $stdout.puts "Still waiting for #{n} more message(s)"
      end # if
    end # subscribe

    system "python ./script/python/pika/publish_to_default_exchange.py"

    done(0.5) {
      number_of_received_messages.should == expected_number_of_messages
    }
  end # it
end # describe
