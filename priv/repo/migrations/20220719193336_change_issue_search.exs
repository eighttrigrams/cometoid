defmodule Cometoid.Repo.Migrations.ChangeIssueSearch do
  use Ecto.Migration

  def change do
    drop index("issues", ["searchable"])

    execute """
      ALTER TABLE issues DROP column searchable
    """, ""

    execute """
      ALTER TABLE issues
      ADD COLUMN searchable tsvector
      GENERATED ALWAYS AS (
        to_tsvector('simple', title || ' ' || short_title || ' ' || tags)
      ) STORED
      """,
      ""

    create index("issues", ["searchable"],
      name: :issues_searchable_index,
      using: "GIN"
    )
  end
end
