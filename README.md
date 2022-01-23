# Cometoid

An issue management system, based on a very simple data model which makes it very versatile. 
In its current state, it is designed to run in a desktop environment, supporting a single user.

## Getting started

### Prerequisites

- Elixir
- A running postgres database

### Preparations

    $ cp config/dev.secret.template.exs config/dev.secret.exs
    $ vim config/dev.secret.exs # Edit settings
    $ mix deps.get
    $ npm i --prefix=./assets
    $ cp -r assets/node_modules/bootstrap-icons/font/fonts priv/static/css
    $ mix ecto.setup

### Start

    $ mix phx.server
    Visit http://localhost:4000

Also provides the hot-code-reload for the editor which is written in ClojureScript. In the js console, a message `shadow-cljs: #x ready!` shows that the websocket connection for shadow-cljs has been established.

For a repl into the running editor environment, run 

    2$ cd assets && npx shadow-cljs cljs-repl app
    cljs.user=> (js/alert "Hi")
    nil

An alert should pop up in the browser. Here as well, new code is compiled and available immediately. Just call your function of choice again after hitting `save`.

### Tests

Run

    $ mix test

To run all tests for the editor, run

    $ cd assets
    $ npm t

For running single tests during development of the editor, run,

a) if `mix phx.server` is running

    $ ./add_testing.sh 
    run-tests=> (require 'editor-test)
    run-tests=> (run-test editor-test/base-case) ;; Hot-code-reloading works. Just edit a file, save and re-run this expression. 
    run-tests=> (run-tests 'editor-test)
    run-tests=> ;; Quit with Ctrl-C, then after "Worker shutdown." appears, press Enter
    
b) otherwise

    $ ./start_testing.sh

Note that hot-code-reloading does not work for both `./start_testing.sh` and `mix phx.server` at the same time, which is why `add_testing.sh` should be used in case both should run.

## Deployment for Production

    $ cp config/dev.secret.template.exs config/dev.secret.exs
    $ cp config/prod.secret.template.exs config/prod.secret.exs
    $ vim config/prod.secret.exs # Edit settings
    $ mix deps.get
    $ cd assets
    $ npm i
    $ npx shadow-cljs release app
    $ cp -r node_modules/bootstrap-icons/font/fonts ../priv/static/css
    $ npm run deploy
    $ cd ..
    $ mix phx.digest
    $ export SECRET_KEY_BASE=SOMESECRETKEYBASE
    $ MIX_ENV=prod mix ecto.setup # or ecto.migrate
    $ MIX_ENV=prod mix phx.server
    Visit http://localhost:4001

## Usage

### Tips

Pressing escape first deselects the selected secondary issues, then the selected context,
then the selected issue.

Double click list items will provide edit menus for contexts and issues. 

Double click on the sidebar will open an editor for the description of the selected context or issue.

Hold control to not show action buttons for list items, which allows then for clicking
secondary context badges in order to jump into the indicated context. Alternatively, first hold right-click. This will prevent the action buttons to be shown, then point to a secondary context badge
and release the right-click (or left-click, which will act on its release) when hovering over the corresponding badge.