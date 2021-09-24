defmodule Cometoid.Repo.Migrations.AddArchivedToEvents do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :archived, :boolean, default: false
    end
  end
end
