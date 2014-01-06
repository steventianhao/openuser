-module(oauth2_riak).

-export([get_redirect_uri/1]).

-define(BUCKET_CLIENT,<<"clients">>).

% only return ok if redirect_uri is non-empty string, else return {error,notfound}
%% TODO
get_redirect_uri(ClientId)->
	case riakcp:exec(get,[?BUCKET_CLIENT,ClientId]) of
		NotFound={error,notfound} -> NotFound;
		{ok,Obj} -> {ok, binary_to_term(riakc_obj:get_value(Obj))}
	end.


	