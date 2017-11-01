%% -*- coding: utf-8 -*-
%%%----------------------------------------------------------------------
%%% @Author  : yangchaojun <YYChildren@gmail.com>
%%% @doc     : 配置存储与查询
%%% @end
%%% @Date    : 2017-02-20 12:39:08
%%%----------------------------------------------------------------------
 
-module(econfig).
-author("yangchaojun").
 
%% API
-export([
    find/2,
    all/1,
    reload_config/1,
    reload_config/2,
    gen_config_src/2
    ]).
 
 
-type spec() :: [{term(), term()},...] | function().
 
-define(CONFIG_FILE(ConfigID), lists:concat([?MODULE, "_", ConfigID])).
-define(CONFIG_MODULE(ConfigID), erlang:list_to_atom(?CONFIG_FILE(ConfigID))).
 
-spec find(ConfigID :: atom(), K :: term()) -> term() | undefined.
find(ConfigID, K) ->
    Mod = ?CONFIG_MODULE(ConfigID),
    Mod:find(K).
 
-spec all(ConfigID :: atom()) -> [{K :: term(), V :: term()},...].
all(ConfigID) ->
    Mod = ?CONFIG_MODULE(ConfigID),
    Mod:all().
 
 
-spec reload_config(ConfigSpec :: {atom(), spec()} | [{atom(), spec()}] | #{}) -> 
    ok | {error, Reason :: term()}.
reload_config(ConfigSpec = #{}) ->
    reload_config(maps:to_list(ConfigSpec));
reload_config(ConfigSpec) when erlang:is_list(ConfigSpec) ->
    lists:foreach(fun({ConfigID, Spec}) -> reload_config({ConfigID, Spec}) end, ConfigSpec);
reload_config({ConfigID, Spec}) ->
    reload_config(ConfigID, Spec).
 
reload_config(ConfigID, DecodeFun) when erlang:is_function(DecodeFun) ->
    reload_config(ConfigID, DecodeFun());
reload_config(ConfigID, DataList) when erlang:is_list(DataList) ->
    FileName = ?CONFIG_FILE(ConfigID),
    Mod = ?CONFIG_MODULE(ConfigID),
    Src = gen_config_src(FileName, lists:keysort(1, DataList)),
    {Mod, Code} = dynamic_compile:from_string(Src),
    case code:load_binary(Mod, FileName ++ ".erl", Code) of
        {module, Mod} ->
            ok;
        {error, What} ->
            error_logger:error_msg("reload ~w fialed for ~w", [ConfigID, What]),
            {error, What}
    end.
 
%% @doc
%% 根据配置文件内容生成erlang代码文件内容
%% 注：运行时生成的include文件必须使用include_lib来引用
%% @end
-spec gen_config_src(FileName, DataList) -> SRC when
  FileName :: string(),
  DataList :: [] | [{term(),term()},...],
  SRC :: string().
gen_config_src(FileName, DataList) ->
  Head = 
"%% -*- coding: utf-8 -*-
-module(" ++ FileName ++ ").
 
%% API
-export([find/1,all/0]).
 
",
  FindCode = gen_src_find(DataList, ""),
  AllCode = gen_src_all(DataList),
  lists:flatten([Head, FindCode, AllCode]).
 
-define(FORMAT(S), io_lib:format("~w", [S])).
 
gen_src_find([], Str) ->
    [Str, "find(_) -> undefined.\n"];
gen_src_find([{Key,Value}|L], Str) ->
    NewStr = [Str, "find(", ?FORMAT(Key), ") -> ",?FORMAT(Value), ";\n"],
    gen_src_find(L, NewStr).
 
gen_src_all(DataList) ->
    ["all() -> ",?FORMAT(DataList) ,".\n"].