# encoding: utf-8

source "http://gemcutter.org"

gem "amqp"
gem "eventmachine"

if RUBY_VERSION < "1.9"
  gem "json"
end

group(:test) do
  gem "rspec", ">=2.0.0"
  gem "amqp-spec", ">=0.3.8"
end
