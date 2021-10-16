defmodule Cometoid.Repo.Migrations.MigrateIssueTypes do
  use Ecto.Migration

  def change do
    execute """
    UPDATE context_issue AS r
    SET issue_type = i.issue_type
    FROM issues AS i
    WHERE r.issue_id = i.id;
    """
  end
end
