defmodule Cometoid.Repo.Migrations.AddPrimaryKeyToContextIssue do
  use Ecto.Migration

  def change do

    execute """
    ALTER TABLE context_issue DROP CONSTRAINT context_task_pkey;
    """

    alter table(:context_issue) do
      add(:id, :serial)
    end
    flush()
    alter table(:context_issue) do
      modify(:id, :integer, primary_key: true)
    end
  end
end
