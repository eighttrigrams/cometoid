# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :cometoid,
  ecto_repos: [Cometoid.Repo]

# Configures the endpoint
config :cometoid, CometoidWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "n+JsRzceeg6Kb0D8X+/5pKjuWB0xDdg2PE8MUruT2Jm+2Nx/Z0fGVL10SjttIub1",
  render_errors: [view: CometoidWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Cometoid.PubSub,
  live_view: [signing_salt: "Fkwuc1Jo"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
