# AMQP 0.9.1 Clients Interoperability Test Suite

AMQP 0.9.1 Clients Interoperability Test Suite (ACITS for short) is a test suite that
verifies compatibility of various AMQP 0.9.1/RabbitMQ clients, for example, the official Java
client, [amqp gem](http://rubyamqp.info), [Pika](http://pika.readthedocs.org/en/latest), the Erlang client and so on.

It does not mean to be the most comprehensive but covers all the common protocol operations, scenarios
and issues observed over about 4 years of using RabbitMQ with various languages.


## How It Works

There is one *main test suite* that delivers commands to *command handlers* implemented in various languages using
various client libraries. The main test suite uses [Langohr](http://clojurerabbitmq.info) and thus the RabbitMQ Java client which is widely considered
to be a reference implementation of a RabbitMQ client.

Commands are distributed over AMQP 0.9.1 and not out of band. There are few reasons for this:

 * It is assumed that clients will be reasonably mature to participate in ACITS, so they should cover all the basic operations
 * Out-of-band options such as IPC, shell-outs (CLI interfaces) or other protocols (e.g. HTTP) will make command handler implementations more complex
   and introduce new issues such as potential port conflicts or slight command-line parsing incompatibilities.

As such, the main test suite delivers commands to various clients and performs assertions on entities they are supposed to declare,
messages they respond with and so on.


## Running Tests

To run the suite, start all the command handlers (currently: `amqp gem`, `pika`) and then run
the main test suite.

### Main Test Suite

Make sure you have JDK 6+ and [Leiningen](http://leiningen.org) installed and available in PATH. Then, from the `langohr` directory:

    lein test

On the first run, this will cause all dependencies to be downloaded.


### amqp gem

Make sure you have Ruby (1.9.3 is recommended, 1.8.7 should work as well, JRuby is supported in both modes). Then

    gem install bundler

and from the `amqp_gem` directory:

    bundle install
    ./script/command_handler.rb


### Pika

Make sure you have Python 2.7 installed. Then

    pip install pika

and from the `pika` directory:

    python ./script/command_handler.py




## License and Copyright

Released under the [Apache Public License 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).

(c) Michael S. Klishin <michael@defprotocol.org>.
