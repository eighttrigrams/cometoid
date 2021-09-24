defmodule Cometoid.Repo.Migrations.AddPersonsTable do
  use Ecto.Migration

  def change do
    create table(:persons) do
      add :context_id, references(:contexts)
      add :name, :string
      add :description, :text

      timestamps()
    end
    alter table(:events) do
      add :person_id, references(:persons, on_delete: :delete_all)
    end
  end
end
