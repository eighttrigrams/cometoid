defmodule Cometoid.Repo.Migrations.AddContextIdToTexts do
  use Ecto.Migration

  def change do
    alter table(:texts) do
      add :context_id, references(:contexts)
    end
  end
end
