defmodule Cometoid.Repo.Migrations.DropPeoplesTable do
  use Ecto.Migration

  def change do
    drop table(:persons)
  end
end
