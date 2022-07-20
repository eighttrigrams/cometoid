defmodule Cometoid.Repo.Migrations.ChangeIssueSearch2 do
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
        to_tsvector('simple', COALESCE(title, '') || ' ' || COALESCE(short_title, '') || ' ' || COALESCE(tags, ''))
      ) STORED
      """,
      ""

    create index("issues", ["searchable"],
      name: :issues_searchable_index,
      using: "GIN"
    )
  end
end
