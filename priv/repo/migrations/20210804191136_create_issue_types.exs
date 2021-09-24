defmodule Cometoid.Repo.Migrations.CreateIssueTypes do
  use Ecto.Migration

  def change do
    create table(:issue_types) do
      add :title, :string

      timestamps()
    end

  end
end
