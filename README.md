What this is
===================

This is a test suite that covers interoperability between Ruby's amqp-gem and various clients
in other languages (for example, Python's Pika and Puka).



How did it come to be?
=======================

Various AMQP clients have different defaults for things like queue or exchange parameters. This
sometimes causes confusion: for example, if both communicating apps declare a queue with different
parameters, broker raises an exception. We started with a couple of scripts to demonstrate that
Ruby and Python apps can, in fact, interoperate, and eventually it became increasingly obvious
that this kind of test suite may be worth doing. Maybe even not so much for harnessing clients
or broker behavior but to keep a bunch of examples how Python, Java, Scala and other applications
can interoperate with Ruby's amqp gem.



Getting started
===================

Dependencies are managed by [Bundler](http://gembundler.com/), so if you don't have that
installed, do

    $ gem install bundler --version ~> "1.0.10"

then use it to install dependencies:

    $ bundle install --deployment

and finally, run spec examples with

    $ bundle exec rspec ./spec
