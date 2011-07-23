#!/bin/env python
# -*- coding: utf-8 -*-

import pika

connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
channel    = connection.channel()


channel.queue_declare(queue = "amqpgem.interoperability.queue", auto_delete = True)
print "Declared queue"

message = "Hello World! Hablamos Español. Привет, AMQP клиент!"

def publish_sample_message():
   channel.basic_publish(exchange = "",
                      routing_key = "amqpgem.interoperability.queue",
                      body        = message)
   print "Published a message"

for i in range(3):
  publish_sample_message()
