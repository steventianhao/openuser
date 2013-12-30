%% @author author <author@example.com>
%% @copyright YYYY author.

%% @doc Callbacks for the openuser application.

-module(openuser_app).
-author('author <author@example.com>').

-behaviour(application).
-export([start/2,stop/1]).


%% @spec start(_Type, _StartArgs) -> ServerRet
%% @doc application start callback for openuser.
start(_Type, _StartArgs) ->
	application:start(riakc_pool),
    openuser_sup:start_link().

%% @spec stop(_State) -> ServerRet
%% @doc application stop callback for openuser.
stop(_State) ->
    ok.
