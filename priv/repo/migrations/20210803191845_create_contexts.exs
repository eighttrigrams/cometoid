defmodule Cometoid.Repo.Migrations.CreateContexts do
  use Ecto.Migration

  def change do
    create table(:contexts) do
      add :title, :string

      timestamps()
    end

  end
end
