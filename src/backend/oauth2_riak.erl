-module(oauth2_riak).

-export([get_redirection_uri/1]).

-define(BUCKET_CLIENT,<<"clients">>).

get_redirection_uri(ClientId)->
	case riakcp:exec(get,[?BUCKET_CLIENT,ClientId]) of
		NotFound={error,notfound} -> NotFound;
		{ok,Obj} -> {ok, binary_to_term(riakc_obj:get_value(Obj))}
	end.


	