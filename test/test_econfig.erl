%% -*- coding: utf-8 -*-
%%%----------------------------------------------------------------------
%%% @author    yangchaojun <YYChildren@gmail.com>
%%% @doc
%%% @end
%%% Created    2017-11-01 22:38:44
%%%----------------------------------------------------------------------

-module(test_econfig).
-author("yangchaojun").

-include_lib("eunit/include/eunit.hrl").

all_test() ->
    KVs = [{1,1}, {2,2}, {3,3}],
    TestCase = [
        {test1, KVs},
        {test2, fun() -> KVs end}
    ],
    lists:foreach(fun({ConfigID, Spec}) ->
        econfig:reload_config({ConfigID, Spec}),
        ?assertEqual(econfig:all(ConfigID), KVs)
    end, TestCase),
    ok = econfig:reload_config(TestCase),
    ok = econfig:reload_config(maps:from_list(TestCase)),
    lists:foreach(fun({ConfigID, _}) -> 
        lists:foreach(fun({K,V}) ->
            ?assertEqual(econfig:find(ConfigID, K), V)
        end, KVs)
    end, TestCase).