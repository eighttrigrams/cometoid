defmodule Cometoid.Repo.Migrations.CreateIssuesToIssues do
  use Ecto.Migration

  def change do
    create table(:issue_issue, primary_key: false) do
      add(:left_id, references(:issues, on_delete: :nothing), primary_key: true)
      add(:right_id, references(:issues, on_delete: :nothing), primary_key: true)
    end

    create(
      unique_index(:issue_issue, [:left_id, :right_id], name: :left_id_right_id_index)
    )
  end
end
