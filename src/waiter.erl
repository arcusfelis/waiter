-module(waiter).
-define(SERVER, ?MODULE).

-export([spawn/1, wait/1, subscribe/1]).

-export([init/1]).

spawn(Fun) when is_function(Fun) ->
	erlang:spawn(?MODULE, init, [Fun]).

wait(Pid) when is_pid(Pid) ->
	erlang:link(Pid),
	subscribe(Pid),

	receive 
		{'waiter_respond', Res} -> 
			erlang:unlink(Pid),
			Res;
		{'waiter_error', _Type, _Reason} = E -> 
			erlang:error(E)
	after 5000 ->
		erlang:error(waiter_timeout)
	end.

subscribe(Pid) when is_pid(Pid) ->
	Pid ! {'waiter_subscribe', self()},
	ok.
	








%% @private
init(Fun) when is_function(Fun) ->
	Msg = try 
		Res = Fun(),
		{'waiter_respond', Res}
	catch
	    throw:Term -> {'waiter_error', 'throw', Term};
	    exit:Reason -> {'waiter_error', 'exit', Reason};
	    error:Reason -> {'waiter_error', 'error', Reason}
	end,
	init_respond(Msg).


init_respond(Msg) ->
    receive
    {'waiter_subscribe', Pid} -> 
		Pid ! Msg,
		init_respond(Msg)
		
    after 10000 -> 
        {error, timeout}
    end.

