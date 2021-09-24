defmodule Cometoid.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :title, :string
      add :date, :date

      timestamps()
    end

  end
end
