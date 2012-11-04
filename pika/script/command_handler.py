import pika, json, sys


class CommandHandler:
  """
  """

  def __init__(self, connection, channel):
    self.connection = connection
    self.channel    = channel
    self.channel.add_on_close_callback(self.on_channel_close)

  def on_channel_close(self, ch):
    print "[error] Channel is closed: %s" % ch
    sys.exit(1)

  def run(self):
    self.channel.queue_declare(queue       = "commands.pika",
                               durable     = True,
                               exclusive   = False,
                               auto_delete = False,
                               callback    = self.on_queue_declared)
    self.handlers = {"exchange.declare": self.handle_exchange_declare,
                     "queue.declare":    self.handle_queue_declare}


  def on_queue_declared(self, queue_declare_ok):
    self.channel.basic_consume(self.handle_delivery, queue = queue_declare_ok.method.queue, no_ack = True)

  def handle_delivery(self, ch, method, metadata, body):
    f = self.handlers.get(metadata.type, self.unknown_message_handler)
    f(method, metadata, json.loads(body))


  def unknown_message_handler(self, method, metadata, body):
    print "Do not know how to handle message of type %s" % metadata.type


  def handle_exchange_declare(self, method, metadata, body):
    is_durable    = body.get('durable', False)
    is_autodelete = body.get('auto-delete', False)
    print "[exchange.declare] Declaring %s of type %s, durable: %s" % (metadata.headers['name'], body['type'], is_durable)
    self.connection.channel(lambda ch: ch.exchange_declare(exchange_type = body['type'], exchange = metadata.headers['name'], durable = is_durable, auto_delete = is_autodelete))

  def no_op(self, *args):
    pass

  def handle_queue_declare(self, method, metadata, body):
    is_durable    = body.get('durable', False)
    is_autodelete = body.get('auto-delete', False)
    print "[queue.declare] Declaring %s, durable: %s" % (metadata.headers['name'], is_durable)
    self.connection.channel(lambda ch: ch.queue_declare(self.no_op, metadata.headers['name'], durable = is_durable, auto_delete = is_autodelete))


class TestSuite:
  """
  """

  def __init__(self, parameters):
    self.connection = pika.SelectConnection(parameters, self.on_connection)

    try:
      self.connection.ioloop.start()
    except KeyboardInterrupt:
      self.connection.close()
      self.connection.ioloop.start()


  def on_connection(self, conn):
    print "Connected"
    conn.channel(self.on_command_channel_open)

  def on_command_channel_open(self, ch):
    print "Opened a channel for commands (%s)" % ch.channel_number
    self.command_handler = CommandHandler(self.connection, ch)
    self.command_handler.run()

handler = TestSuite(pika.ConnectionParameters())
