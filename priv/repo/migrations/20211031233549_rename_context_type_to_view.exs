defmodule Cometoid.Repo.Migrations.RenameContextTypeToView do
  use Ecto.Migration

  def change do
    rename table(:contexts), :context_type, to: :view
  end
end
