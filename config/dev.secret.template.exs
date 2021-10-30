use Mix.Config

config :cometoid,
  data_path: "./data/",

  context_types: [
    %{ name: "View-1", context_types: "List" },
    %{ name: "View-1a", context_types: "A:List_B:List2_B:List3_B:List4_B:List5_B:List6" },
    %{ name: "View-2", context_types: "Project_Component_Version_IssueType" }
  ]

config :cometoid, Cometoid.Repo,
  username: "USERNAME",
  password: "PASSWORD",
  database: "DATABASE",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
