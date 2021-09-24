defmodule Cometoid.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :title, :string
      add :description, :string
      add :type, :string
      add :done, :boolean, default: false, null: false

      timestamps()
    end
  end
end
