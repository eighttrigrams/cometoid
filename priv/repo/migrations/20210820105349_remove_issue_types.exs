defmodule Cometoid.Repo.Migrations.RemoveIssueTypes do
  use Ecto.Migration

  def change do
    alter table(:issues) do
      add :issue_type, :string
    end
    execute("UPDATE issues SET issue_type=issue_types.title " <>
            "FROM issue_types " <>
            "WHERE issues.issue_type_id=issue_types.id")
    alter table(:issues) do
      remove :issue_type_id
    end
    drop table(:issue_types)
  end
end
