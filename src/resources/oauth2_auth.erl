-module(oauth2_auth).
-export([init/1,allowed_methods/2,content_types_provided/2,process_get/2,process_post/2]).

-include_lib("webmachine/include/webmachine.hrl").

% response_type="code"
%access_type="online"|"offline" default is online
%approval_prompt="force"|"auto" default is auto
%login_hint
%include_granted_scopes=true|false

-record(oauth2webserver,{
	response_type="code",client_id,redirect_uri,scope,state,access_type="online",
	approval_prompt="auto",login_hint,include_granted_scopes="true"}).

init([])->
	{ok,undefined}.

allowed_methods(ReqData,Context)->
	{['GET','POST'],ReqData,Context}.

content_types_provided(ReqData,Context)->
	{[{"text/html",process_get},{"text/html",process_post}],ReqData,Context}.

process_post(ReqData,Context)->
	P=extract_parameters(http_utils:parse_body(ReqData)),
	case P#oauth2webserver.client_id of 
		undefined->
			{ok,Body}=bad_request_dtl:render([]),
			{{halt,400},wrq:set_resp_body(Body,ReqData),Context};
		_ClientId ->
			Body=io_lib:format("<html><body>hello nimei ~p,~p</body></html>",[ReqData,P]),
			{Body,ReqData,Context}
	end.

process_get(ReqData,Context)->
	P=extract_parameters(wrq:req_qs(ReqData)),
	case P#oauth2webserver.client_id of 
		undefined->
			{ok,Body}=bad_request_dtl:render([]),
			{{halt,400},wrq:set_resp_body(Body,ReqData),Context};
		_ClientId ->
			Body=io_lib:format("<html><body>hello nimei ~p,~p</body></html>",[ReqData,P]),
			{Body,ReqData,Context}
	end.



extract_parameters(ReqData)->
	ResponseType=http_utils:get_qs_value("response_type",ReqData),
	ClientId=http_utils:get_qs_value("client_id",ReqData),
	RedirectUri=http_utils:get_qs_value("redirect_uri",ReqData),
	Scope=http_utils:get_qs_value("scope",ReqData),
	State=http_utils:get_qs_value("state",ReqData),
	AccessType=http_utils:get_qs_value("access_type","online",ReqData),
	ApprovalPrompt=http_utils:get_qs_value("approval_prompt","auto",ReqData),
	LoginHint=http_utils:get_qs_value("login_hint",ReqData),
	IncludeGrantedScopes=http_utils:get_qs_value("include_granted_scopes","true",ReqData),
	#oauth2webserver{response_type=ResponseType,client_id=ClientId,
	redirect_uri=RedirectUri,scope=Scope,state=State,
	access_type=AccessType,approval_prompt=ApprovalPrompt,
	login_hint=LoginHint,include_granted_scopes=IncludeGrantedScopes}.


