defmodule Cometoid.Repo.Migrations.AddShortTitleToContext do
  use Ecto.Migration

  def change do
    alter table :contexts do
      add :short_title, :string
    end
  end
end
