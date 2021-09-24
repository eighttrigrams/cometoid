defmodule Cometoid.Repo.Migrations.CreateTexts do
  use Ecto.Migration

  def change do
    create table(:texts) do
      add :title, :string
      add :description, :text
      add :type, :string
      add :audience, :string

      timestamps()
    end

  end
end
