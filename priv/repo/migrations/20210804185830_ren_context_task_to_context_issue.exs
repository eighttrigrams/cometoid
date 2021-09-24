defmodule Cometoid.Repo.Migrations.RenContextTaskToContextIssue do
  use Ecto.Migration

  def change do
    rename table(:context_task), to: table(:context_issue)
    rename table(:context_issue), :task_id, to: :issue_id
  end
end
