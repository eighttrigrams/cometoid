defmodule Cometoid.Repo.Migrations.AddShortTitleToIssue do
  use Ecto.Migration

  def change do
    alter table :issues do
      add :short_title, :string
    end
  end
end
