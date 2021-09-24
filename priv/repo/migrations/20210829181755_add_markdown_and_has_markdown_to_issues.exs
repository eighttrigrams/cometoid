defmodule Cometoid.Repo.Migrations.AddMarkdownAndHasMarkdownToIssues do
  use Ecto.Migration

  def change do
    alter table(:issues) do
      add :markdown, :text
      add :has_markdown, :boolean
    end
  end
end
