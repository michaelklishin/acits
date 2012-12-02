-module(acits_app).

-behaviour(application).

%% Application callbacks
-export([start/0, start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start() ->
    ok = application:start(amqp_client),
    ok = application:start(acits).

start(_StartType, _StartArgs) ->
    acits_sup:start_link().

stop(_State) ->
    ok.
