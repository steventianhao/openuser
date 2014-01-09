-module(oauth2_riak).

-export([get_nonempty_redirect_uri/1]).

-define(BUCKET_CLIENT,<<"clients">>).

-record(client,{name::string(),client_id::string(),client_secret::string(),redirect_uri::string()}).

% only return ok if redirect_uri is non-empty string, else return {error,notfound}
-spec get_nonempty_redirect_uri(ClientId::string()) -> {error,notfound} | {ok,string()}.
get_nonempty_redirect_uri(ClientId)->
	case riakcp:exec(get,[?BUCKET_CLIENT,list_to_binary(ClientId)]) of
		NotFound={error,notfound} -> 
			NotFound;
		{ok,Obj} -> 
			#client{redirect_uri=RedirectUri}=binary_to_term(riakc_obj:get_value(Obj)),
			case RedirectUri of 
				"" -> {error,notfound};
				_ -> {ok, RedirectUri}
			end
	end.