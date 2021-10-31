use Mix.Config

config :cometoid,
  views: ["Software"]

config :cometoid, Cometoid.Repo,
  username: "USERNAME",
  password: "PASSWORD",
  database: "DATABASE",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
