%% @author author <author@example.com>
%% @copyright YYYY author.
%% @doc Example webmachine_resource.

-module(openuser_resource).
-export([init/1, to_html/2, to_text/2,content_types_provided/2]).

-include_lib("webmachine/include/webmachine.hrl").

init([]) -> {ok, undefined}.

content_types_provided(ReqData,Context)->
	Types=[{"text/html",to_html},{"text/plain",to_text}],
	{Types,ReqData,Context}.

to_html(ReqData, State) ->
	{ok,[Value]}=riakcp:exec(list_keys,[<<"groceries">>]),
	{ok,Result}=sample_dtl:render([{param,Value}]),
    {Result, ReqData, State}.

to_text(ReqData,State) ->
	Path = wrq:disp_path(ReqData),
	Body = io_lib:format("Hello ~s from webmachine. ~n",[Path]),
	{Body, ReqData, State}.