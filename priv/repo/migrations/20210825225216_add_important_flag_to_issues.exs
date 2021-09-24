defmodule Cometoid.Repo.Migrations.AddImportantFlagToIssues do
  use Ecto.Migration

  def change do
    alter table(:issues) do
      add :important, :boolean, default: false
    end
  end
end
