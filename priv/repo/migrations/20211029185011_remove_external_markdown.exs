defmodule Cometoid.Repo.Migrations.RemoveExternalMarkdown do
  use Ecto.Migration

  def change do
    alter table(:issues) do
      remove :has_markdown
      remove :markdown
    end
  end
end
