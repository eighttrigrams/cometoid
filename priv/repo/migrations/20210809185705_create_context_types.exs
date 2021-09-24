defmodule Cometoid.Repo.Migrations.CreateContextTypes do
  use Ecto.Migration

  def change do
    create table(:context_types) do
      add :title, :string

      timestamps()
    end

  end
end
