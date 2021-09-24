defmodule Cometoid.Repo.Migrations.AddContextTypeIdToContext do
  use Ecto.Migration

  def change do
    alter table(:contexts) do
      add :context_type_id, references(:context_types, on_delete: :nothing)
    end
  end
end
