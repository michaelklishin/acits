-module(acits).

-export([start/0]).

start() ->
    ok = application:start(amqp_client),
    ok = application:start(acits).
