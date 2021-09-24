defmodule Cometoid.Repo.Migrations.LinkEventsToIssues do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :issue_id, references(:issues)
    end
  end
end
