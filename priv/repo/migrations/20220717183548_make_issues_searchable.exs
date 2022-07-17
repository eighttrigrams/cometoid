defmodule Cometoid.Repo.Migrations.MakeIssuesSearchable do
  use Ecto.Migration

  def change do
    execute """
      ALTER TABLE issues
      ADD COLUMN searchable tsvector
      GENERATED ALWAYS AS (
        to_tsvector('simple', title)
      ) STORED
      """,
      "ALTER TABLE tips DROP COLUMN searchable"
        
    create index("issues", ["searchable"],
      name: :issues_searchable_index,
      using: "GIN"
    )
  end
end
