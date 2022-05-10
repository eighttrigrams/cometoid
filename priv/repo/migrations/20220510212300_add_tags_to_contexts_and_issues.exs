defmodule Cometoid.Repo.Migrations.AddTagsToContextsAndIssues do
  use Ecto.Migration

  def change do
    alter table :contexts do
      add :tags, :string, default: ""
    end
    alter table :issues do
      add :tags, :string, default: ""
    end

    execute """
    UPDATE contexts SET tags = '';    
    """

    execute """
    UPDATE issues SET tags = '';
    """
  end
end
