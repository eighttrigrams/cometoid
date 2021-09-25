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
