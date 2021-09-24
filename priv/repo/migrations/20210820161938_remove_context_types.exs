defmodule Cometoid.Repo.Migrations.RemoveContextTypes do
  use Ecto.Migration

  def change do
    alter table(:contexts) do
      add :context_type, :string
    end
    execute("UPDATE contexts SET context_type=context_types.title " <>
            "FROM context_types " <>
            "WHERE contexts.context_type_id=context_types.id")
    alter table(:contexts) do
      remove :context_type_id
    end
    drop table(:context_types)
  end
end
