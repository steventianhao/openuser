-module(oauth2_auth).
-export([init/1,allowed_methods/2,content_types_provided/2,process_get/2,process_post/2]).

-include_lib("webmachine/include/webmachine.hrl").

init([])->
	{ok,undefined}.

allowed_methods(ReqData,Context)->
	{['GET','POST'],ReqData,Context}.

content_types_provided(ReqData,Context)->
	{[{"text/html",process_get},{"text/html",process_post}],ReqData,Context}.

process_post(ReqData,Context)->
	Body=io_lib:format("<html><body>aaa</body></html>",[]),
	{Body,ReqData,Context}.

process_get(ReqData,Context)->
	Body=io_lib:format("hello",[]),
	{Body,ReqData,Context}.
