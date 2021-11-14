defmodule Cometoid.Repo.Migrations.AddUseBirthdayToPerson do
  use Ecto.Migration

  def change do
    alter table :persons do
      add :use_birthday, :boolean
    end
  end
end
