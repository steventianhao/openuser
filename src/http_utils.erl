-module(http_utils).
-include_lib("webmachine/include/wm_reqdata.hrl").
-export([parse_body/1,get_qs_value/2,get_qs_value/3]).

parse_body(Request) ->
    case wrq:req_body(Request) of
        undefined ->
            [];
        <<>> ->
            [];
        Body ->
            mochiweb_util:parse_qs(Body)
    end.

get_qs_value(_Key,[])->
	undefined;
get_qs_value(Key,Params) ->
	case lists:keyfind(Key, 1, Params) of
        {Key, Value} ->
            Value;
        false ->
            undefined
    end.
get_qs_value(_Key,Default,[])->
	Default;
get_qs_value(Key,Default,Params)->
	case lists:keyfind(Key, 1, Params) of
        {Key, Value} ->
            Value;
        false ->
            Default
    end.
	