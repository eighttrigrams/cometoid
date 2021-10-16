defmodule Cometoid.Repo.Migrations.AddIssueTypeToRelation do
  use Ecto.Migration

  def change do
    alter table(:context_issue) do
      add(:issue_type, :string)
    end
  end
end
