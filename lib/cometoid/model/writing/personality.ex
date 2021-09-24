defmodule Cometoid.Model.Writing.Personality do
  use Ecto.Schema
  import Ecto.Changeset

  alias Cometoid.Model.Writing

  schema "personalities" do
    field :name, :string

    has_many :readings, Writing.PersonalityRole, on_replace: :delete, on_delete: :delete_all, foreign_key: :personality_id

    timestamps()
  end

  @doc false
  def changeset(personality, attrs) do
    personality
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
