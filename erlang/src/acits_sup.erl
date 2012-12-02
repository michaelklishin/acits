-module(acits_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).


%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    AcitsSpec = {acits_handlers,
                 {acits_handlers, start_link, []},
                 transient,
                 5000,
                 worker, [acits_handlers]},
    {ok, {{one_for_one, 3, 3}, [AcitsSpec]}}.

