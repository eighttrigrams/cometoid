defmodule Cometoid.Repo.Migrations.MakeIssueTypeAReference do
  use Ecto.Migration

  def change do
    alter table(:issues) do
      remove :type
      add :issue_type_id, references(:issue_types)
    end
  end
end
