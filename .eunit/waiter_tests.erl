-module(waiter_tests).

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

waiter_test_() ->
	Pid = waiter:spawn(fun() -> 'test_result' end),
	?_assertEqual('test_result', waiter:wait(Pid)).

-endif.
