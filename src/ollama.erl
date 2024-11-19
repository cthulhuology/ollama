%% ollama
%%
%% MIT No Attribution  
%% Copyright 2023 David J Goehrig <dave@dloh.org>
%%
%% Permission is hereby granted, free of charge, to any person obtaining a copy 
%% of this software and associated documentation files (the "Software"), to 
%% deal in the Software without restriction, including without limitation the 
%% rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
%% sell copies of the Software, and to permit persons to whom the Software is 
%% furnished to do so.  
%%
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
%% FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
%% IN THE SOFTWARE.



-module(ollama).
-author({ "David J Goehrig", "dave@dloh.org" }).
-copyright(<<"© 2024 David J Goehrig"/utf8>>).
-behavior(gen_server).
-export([ start_link/0, start_link/1, stop/0, response/1, response/2, generate/1, embed/1, dump/1 ]).
-export([ code_change/3, handle_call/3, handle_cast/2, handle_info/2, init/1,
	terminate/2 ]).

-record(ollama_client, { http, url, module, function }).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Public API
%

start_link() ->
	start_link("http://172.17.32.1:11434").

start_link(Url) ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, #ollama_client{ url = Url, module  = ?MODULE, function = dump }, []).

stop() ->
	gen_server:call(?MODULE,stop).

generate(Prompt) when is_list(Prompt) ->
	generate(list_to_binary(Prompt));
generate(Prompt) ->
	gen_server:cast(?MODULE, { generate, Prompt }).

embed(Prompt) ->
	gen_server:cast(?MODULE, { embed, Prompt }).

response(Module,Function) ->
	gen_server:cast(?MODULE, { response, Module, Function }).

response(Fun) ->
	gen_server:cast(?MODULE, { response, Fun }).

dump(Body) ->
	error_logger:info_msg("~p~n", [ Body ]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Private API
%

init(Client = #ollama_client{ }) ->
	HTTP = http:start(),
	{ ok, Client#ollama_client{ http = HTTP } }.

handle_call(stop, _From, State) ->
	http:stop(),
	{ stop, ok, State };

handle_call(_,_,State) ->
	{ reply, ok, State }.

handle_cast({ generate, Prompt }, State = #ollama_client{ url = Url, module = Mod, function = Fun }) ->
	case Mod of 
		none -> http:then(Fun);
		Mod -> http:then(fun(Body) -> Mod:Fun(json:decode(Body)) end)
	end,
	http:post(Url ++ "/api/generate", json:encode([
		{<<"model">>,<<"llama3.2">>},
		{<<"prompt">>, Prompt },
		{<<"stream">>,false}])),
	{ noreply, State };

handle_cast({ embed, Input }, State = #ollama_client{ url = Url, module = Mod, function = Fun }) ->
	case Mod of 
		none -> http:then(Fun);
		Mod -> http:then(fun(Body) -> Mod:Fun(json:decode(Body)) end)
	end,
	http:post(Url ++ "/api/generate", json:encode([
		{<<"model">>,<<"llama3.2">>},
		{<<"input">>, Input },
		{<<"stream">>,false}])),
	{ noreply, State };

handle_cast({ response, Module, Function }, State) ->
	{ noreply, State#ollama_client{ module = Module, function = Function } };

handle_cast({ response, Function }, State) ->
	{ noreply, State#ollama_client{ module = none, function = Function } };

handle_cast(Message, State) ->
	error_logger:error_msg("Unknown message ~p~n", [ Message ]),
	{ noreply, State }.

handle_info(_, State) ->
	{ noreply, State }.

terminate(reason,State) ->
	http:stop(),
	{ ok, State }.

code_change(_New,_Old,State) ->
	{ ok, State }.

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

ollama_result(Body) ->
	error_logger:info_msg("~p~n",[Body]).

ollama_test() ->
	ollama:start_link("http://172.17.32.1:11434"),
	ollama:response(ollama,ollama_result),
	ollama:generate("Write me a poem").
-endif.
