use Mix.Config

config :cometoid,
  theme: "2",

  data_path: "./data/",

  context_types: [
    %{ name: "View-1", context_types: "List" },
    %{ name: "View-2", context_types: "Todolist_Context type 2" }
  ],
  issue_types: %{
    "List" => ["Item"],
    "Todolist" => ["Todo"],
    "Context type 2" => ["Issue type A", "Issue Type B"],
  }

config :cometoid, Cometoid.Repo,
  username: "USERNAME",
  password: "PASSWORD",
  database: "DATABASE",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
