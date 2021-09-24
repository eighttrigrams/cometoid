defmodule Cometoid.Repo.Migrations.ConnectTaskToContext do
  use Ecto.Migration

  def change do
    create table(:context_task, primary_key: false) do
      add(:context_id, references(:contexts), primary_key: true)
      add(:task_id, references(:tasks), primary_key: true)
    end

    create(index(:context_task, [:context_id]))
    create(index(:context_task, [:task_id]))
  end
end
