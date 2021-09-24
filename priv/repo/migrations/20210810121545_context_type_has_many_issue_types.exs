defmodule Cometoid.Repo.Migrations.ContextTypeHasManyIssueTypes do
  use Ecto.Migration

  def change do
    alter table(:issue_types) do
      add :context_type_id, references(:context_types)
    end
  end
end
