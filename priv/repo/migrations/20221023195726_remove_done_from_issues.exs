defmodule Cometoid.Repo.Migrations.RemoveDoneFromIssues do
  use Ecto.Migration

  def change do
    alter table :issues do
      remove :done
    end
  end
end
