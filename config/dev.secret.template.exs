use Mix.Config

config :cometoid,
  data_path: "./data/",

  context_types: [
    %{ name: "Software", context_types: "Software:Project_Software:Component_Software:Version_Software:IssueType_Software:Epic" }
  ]

config :cometoid, Cometoid.Repo,
  username: "USERNAME",
  password: "PASSWORD",
  database: "DATABASE",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
