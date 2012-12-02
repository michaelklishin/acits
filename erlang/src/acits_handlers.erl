-module(acits_handlers).

-behaviour(gen_server2).

-include("../deps/amqp_client/include/amqp_client.hrl").

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {connection,
                channel,
                command_queue,
                command_queue_consumer_tag}).

%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
    gen_server:cast(self(), init),
    {ok, #state{command_queue = <<"commands.erlang-amqp-client">>}}.

handle_cast(init, State = #state{command_queue = CommandQ}) ->
    process_flag(trap_exit, true),
    {ok, Connection}  = amqp_connection:start(#amqp_params_network{}),
    {ok, Channel}     = amqp_connection:open_channel(Connection),
    link(Connection),
    link(Channel),
    #'basic.qos_ok'{} = amqp_channel:call(Channel, #'basic.qos'{prefetch_count = 1}),
    #'queue.declare_ok'{} = amqp_channel:call(Channel, #'queue.declare'{queue = CommandQ, durable = true}),
    io:format("Declared the command queue: ~p~n", [CommandQ]),
    amqp_selective_consumer:register_default_consumer(Channel, self()),
    #'basic.consume_ok'{consumer_tag = CTag} = amqp_channel:subscribe(Channel, #'basic.consume'{queue  = CommandQ,
                                                                                                consumer_tag = <<"">>}, self()),
    State1 = State#state{connection    = Connection,
                         channel       = Channel,
                         command_queue = CommandQ,
                         command_queue_consumer_tag = CTag},
    {noreply, State1};

handle_cast(_Msg, State) ->
    io:format("handle_cast~n"),
    {noreply, State}.


handle_info(#'basic.consume_ok'{}, State) ->
    {noreply, State};

handle_info({#'basic.deliver'{delivery_tag = Tag}, #amqp_msg{props = #'P_basic'{type = Type,
                                                                                headers = Headers},
                                                             payload = Payload}}, State = #state{channel = Ch}) ->
    Json = jsx:decode(Payload),
    io:format("Delivery ~p, type: ~p, headers: ~p~n", [Json, Type, Headers]),
    handle_command(Type, Json, Headers, State),
    amqp_channel:cast(Ch, #'basic.ack'{delivery_tag = Tag}),
    {noreply, State};

handle_info(_Info, State) ->
    io:format("handle_info~n"),
    {ok, State}.


handle_call(_Msg, _From, State) ->
    io:format("handle_call~n"),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%%
%% Internal
%%

handle_command(<<"queue.declare">>, Json, Headers, #state{connection = Connection}) ->
    {ok, Ch} = amqp_connection:open_channel(Connection),
    Durable = proplists:get_value(<<"durable">>, Json),
    AutoDel = proplists:get_value(<<"auto-delete">>, Json, false),
    QName   = extract_header(<<"name">>, Headers),
    io:format("Declaring a queue, name: ~p, durable: ~p~n", [Durable, QName]),
    #'queue.declare_ok'{} = amqp_channel:call(Ch, #'queue.declare'{queue   = QName,
                                                                   durable = Durable,
                                                                   auto_delete = AutoDel});
handle_command(<<"exchange.declare">>, Json, Headers, #state{connection = Connection}) ->
    {ok, Ch} = amqp_connection:open_channel(Connection),
    Durable = proplists:get_value(<<"durable">>, Json),
    AutoDel = proplists:get_value(<<"auto-delete">>, Json, false),
    EType   = proplists:get_value(<<"type">>, Json),
    EName   = extract_header(<<"name">>, Headers),
    io:format("Declaring an exchange, name: ~p, durable: ~p~n", [Durable, EName]),
    #'exchange.declare_ok'{} = amqp_channel:call(Ch, #'exchange.declare'{exchange = EName,
                                                                         durable  = Durable,
                                                                         type     = EType,
                                                                         auto_delete = AutoDel}).

extract_header(Name, Headers) ->
    {Name, _, V} = lists:keyfind(Name, 1, Headers),
    V.
