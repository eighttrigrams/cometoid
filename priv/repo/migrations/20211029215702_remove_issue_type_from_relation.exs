defmodule Cometoid.Repo.Migrations.RemoveIssueTypeFromRelation do
  use Ecto.Migration

  def change do
    alter table(:context_issue) do
      remove :issue_type
    end
  end
end
