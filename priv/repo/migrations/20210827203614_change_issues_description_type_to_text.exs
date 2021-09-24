defmodule Cometoid.Repo.Migrations.ChangeIssuesDescriptionTypeToText do
  use Ecto.Migration

  def change do
    alter table(:issues) do
      modify :description, :text
    end
  end
end
