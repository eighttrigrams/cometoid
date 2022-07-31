defmodule Cometoid.Repo.Migrations.MakeContextsSearchable do
  use Ecto.Migration

  def change do
    execute """
      ALTER TABLE contexts
      ADD COLUMN searchable tsvector
      GENERATED ALWAYS AS (
        to_tsvector('simple', COALESCE(title, '') || ' ' || COALESCE(short_title, '') || ' ' || COALESCE(tags, ''))
      ) STORED
      """,
      ""

    create index("contexts", ["searchable"],
      name: :contexts_searchable_index,
      using: "GIN"
    )
  end
end
