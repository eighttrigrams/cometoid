# Cometoid

An issue management system, based on a very simple data model which makes it very versatile. 
In its current state, it is designed to run in a desktop environment, supporting a single user.

## Getting started

### Prerequisites

- Elixir
- A running postgres database

### Start Development

    $ cp config/dev.secret.template.exs config/dev.secret.exs
    $ vim config/dev.secret.exs # Edit settings
    $ mkdir data                # or use an existing dir, see data_path in config
    $ mix deps.get
    $ npm i --prefix ./assets
    $ mix ecto.setup
    $ mix phx.server
    Visit http://localhost:4000

### Deploy for Production

    $ cp config/dev.secret.template.exs config/dev.secret.exs
    $ cp config/prod.secret.template.exs config/prod.secret.exs
    $ vim config/prod.secret.exs # Edit settings
    $ mkdir data                 # or use an existing dir, see data_path in config
    $ mix deps.get
    $ npm i --prefix ./assets
    $ npm run deploy --prefix ./assets && mix phx.digest
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

## Tests

Run

    $ mix test