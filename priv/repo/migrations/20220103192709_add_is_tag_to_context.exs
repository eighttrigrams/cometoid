defmodule Cometoid.Repo.Migrations.AddIsTagToContext do
  use Ecto.Migration

  def change do
    alter table :contexts do
      add :is_tag, :boolean, default: false
    end
  end
end
