defmodule Cometoid.Repo.Migrations.AddSearchModeToContexts do
  use Ecto.Migration

  def change do
    alter table :contexts do
      add :search_mode, :smallint
    end
  end
end
