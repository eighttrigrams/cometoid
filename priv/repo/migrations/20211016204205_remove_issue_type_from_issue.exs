defmodule Cometoid.Repo.Migrations.RemoveIssueTypeFromIssue do
  use Ecto.Migration

  def change do
    alter table(:issues) do
      remove :issue_type
    end
  end
end
