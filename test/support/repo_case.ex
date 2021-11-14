defmodule Cometoid.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Cometoid.Repo

      import Ecto
      import Ecto.Query
      import Cometoid.RepoCase

      # and any other stuff
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Cometoid.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Cometoid.Repo, {:shared, self()})
    end

    :ok
  end
end
