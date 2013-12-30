%% @author author <author@example.com>
%% @copyright YYYY author.

%% @doc openuser startup code

-module(openuser).
-author('author <author@example.com>').
-export([start/0, start_link/0, stop/0]).

ensure_started(App) ->
    case application:start(App) of
        ok ->
            ok;
        {error, {already_started, App}} ->
            ok
    end.

%% @spec start_link() -> {ok,Pid::pid()}
%% @doc Starts the app for inclusion in a supervisor tree
start_link() ->
    ensure_started(inets),
    ensure_started(crypto),
    ensure_started(riakc_pool),
    ensure_started(mochiweb),
    application:set_env(webmachine, webmachine_logger_module, 
                        webmachine_logger),
    application:set_env(webmachine,server_name,"fuleyou"),
    ensure_started(webmachine),
    openuser_sup:start_link().

%% @spec start() -> ok
%% @doc Start the openuser server.
start() ->
    ensure_started(inets),
    ensure_started(crypto),
    ensure_started(riakc_pool),
    ensure_started(mochiweb),
    application:set_env(webmachine, webmachine_logger_module, 
                        webmachine_logger),
    application:set_env(webmachine,server_name,"fuleyou"),
    ensure_started(webmachine),
    application:start(openuser).

%% @spec stop() -> ok
%% @doc Stop the openuser server.
stop() ->
    Res = application:stop(openuser),
    application:stop(webmachine),
    application:stop(mochiweb),
    application:stop(riakc_pool),
    application:stop(crypto),
    application:stop(inets),
    Res.
