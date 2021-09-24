defmodule Cometoid.Repo.Migrations.CreatePersons do
  use Ecto.Migration

  def change do
    create table(:persons) do
      add :name, :string
      add :birthdate, :date
      add :description, :text

      timestamps()
    end

  end
end
