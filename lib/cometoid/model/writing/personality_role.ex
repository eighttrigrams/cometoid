defmodule Cometoid.Model.Writing.PersonalityRole do
  use Ecto.Schema
  import Ecto.Changeset

  alias Cometoid.Model.Writing

  schema "personality_reading" do

    belongs_to :personality, Writing.Personality
    belongs_to :reading, Writing.Reading
  end

  @doc false
  def changeset(personality_role, attrs) do

    personality_role
    |> cast(attrs, [])
  end
end
