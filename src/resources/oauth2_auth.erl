-module(oauth2_auth).
-export([init/1,allowed_methods/2,content_types_provided/2,process_get/2,process_post/2]).

-include_lib("webmachine/include/webmachine.hrl").

-define(RESPONSE_TYPE,"response_type").
-define(CLIENT_ID,"client_id").
-define(REDIRECT_URI,"redirect_uri").
-define(SCOPE,"scope").
-define(STATE,"state").
-define(ACCESS_TYPE,"access_type").
-define(APPROVAL_PROMPT,"approval_prompt").
-define(LOGIN_HINT,"login_hint").
-define(INCLUDE_GRANTED_SCOPES,"include_granted_scopes").

-define(ONLINE,"online").
-define(CODE,"code").
-define(TRUE,"true").
-define(AUTO,"auto").


% response_type="code"
%access_type="online"|"offline" default is online
%approval_prompt="force"|"auto" default is auto
%login_hint
%include_granted_scopes=true|false

-record(oauth2webserver,{
	response_type=?CODE,client_id,redirect_uri,scope,state,access_type=?ONLINE,
	approval_prompt=?AUTO,login_hint,include_granted_scopes=?TRUE}).

extract_parameters(ReqData)->
	ResponseType=http_utils:get_qs_value(?RESPONSE_TYPE,ReqData),
	ClientId=http_utils:get_qs_value(?CLIENT_ID,ReqData),
	RedirectUri=http_utils:get_qs_value(?REDIRECT_URI,ReqData),
	Scope=http_utils:get_qs_value(?SCOPE,ReqData),
	State=http_utils:get_qs_value(?STATE,ReqData),
	AccessType=http_utils:get_qs_value(?ACCESS_TYPE,?ONLINE,ReqData),
	ApprovalPrompt=http_utils:get_qs_value(?APPROVAL_PROMPT,?AUTO,ReqData),
	LoginHint=http_utils:get_qs_value(?LOGIN_HINT,ReqData),
	IncludeGrantedScopes=http_utils:get_qs_value(?INCLUDE_GRANTED_SCOPES,?TRUE,ReqData),
	
	#oauth2webserver{response_type=ResponseType,client_id=ClientId,
	redirect_uri=RedirectUri,scope=Scope,state=State,
	access_type=AccessType,approval_prompt=ApprovalPrompt,
	login_hint=LoginHint,include_granted_scopes=IncludeGrantedScopes}.

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
	Oauth2Rec=extract_parameters(wrq:req_qs(ReqData)),
	case Oauth2Rec#oauth2webserver.client_id of 
		undefined->
			{ok,Body}=bad_request_dtl:render([]),
			{{halt,400},wrq:set_resp_body(Body,ReqData),Context};
		_ClientId ->
			handle_redirect_uri(ReqData,Context,Oauth2Rec)
	end.


compare_redirect_uri(RegisteredUri,RedirectUri)->
	case {RegisteredUri,RedirectUri} of
		 {Uri,Uri} -> {match,equal};
		 {_Uri,undefined} -> {match, no_parameter};
		 _ -> mismatch
	end.


handle_redirect_uri(ReqData,Context,Oauth2Rec)->
	#oauth2webserver{client_id=ClientId,redirect_uri=RedirectUri}=Oauth2Rec,
	case oauth2_riak:get_nonempty_redirect_uri(ClientId) of
		{ok,RegisteredUri} ->
		 	case compare_redirect_uri(RegisteredUri,RedirectUri) of
		 		{match, _} ->
		 			 {ok,Body}=authorization_form_dtl:render([]),
		 			 {Body,ReqData,Context};
		 		mismatch ->
		 			{ok,Body}=invalid_redirect_uri_dtl:render([]),
					{{halt,401},wrq:set_resp_body(Body,ReqData),Context}
			end;
		{error,notfound} ->
			{ok,Body}=unauthorized_client_dtl:render([]),
			{{halt,403},wrq:set_resp_body(Body,ReqData),Context}
	end.