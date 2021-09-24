defmodule Cometoid.Repo.Migrations.RenTasksToIssues do
  use Ecto.Migration

  def change do
    rename table(:tasks), to: table(:issues)
  end
end
