econfig
=====

基于erlang动态编译的简单配置方案

特点
=====
1. 配置编译进代码区，无锁，因此访问配置非常快
2. 由于是基于动态编译，在配置较多的情况下编译时间较长

例子
=====
```erlang
KVs = [{1,1}, {2,2}, {3,3}],
TestCase = [
    {test1, KVs},
    {test2, fun() -> KVs end}
],

econfig:reload_config(TestCase),
%% or
[econfig:reload_config(TestCase) || C <- TestCase],

%% 访问单个配置
1 = econfig:find(test1, 1),

%% 访问不存在的配置
undefined = econfig:all(4),

%% 访问所有配置（根据key排序）
KVs = econfig:all(test1).
```

Build
-----
```bash
rebar compile
# or
rebar3 compile
```
    
