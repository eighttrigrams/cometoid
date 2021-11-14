defmodule Cometoid.Repo.Migrations.AddBirthdayToPerson do
  use Ecto.Migration

  def change do
    alter table :persons do
      add :birthday, :date
    end
  end
end
