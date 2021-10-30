defmodule Cometoid.Repo.Migrations.CreateContextsToContexts do
  use Ecto.Migration

  def change do
    create table(:context_context, primary_key: false) do
      add(:parent_id, references(:contexts, on_delete: :nothing), primary_key: true)
      add(:child_id, references(:contexts, on_delete: :nothing), primary_key: true)
    end

    create(
      unique_index(:context_context, [:parent_id, :child_id], name: :parent_id_child_id_index)
    )
  end
end
