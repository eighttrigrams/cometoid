defmodule Cometoid.Repo.Migrations.AddDescriptionToContexts do
  use Ecto.Migration

  def change do
    alter table(:contexts) do
      add :description, :text
    end
  end
end
