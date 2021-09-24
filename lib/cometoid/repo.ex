defmodule Cometoid.Repo do
  use Ecto.Repo,
    otp_app: :cometoid,
    adapter: Ecto.Adapters.Postgres
end
