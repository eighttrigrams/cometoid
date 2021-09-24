defmodule Cometoid.Model.Writing.Reading do
  use Ecto.Schema
  import Ecto.Changeset

  alias Cometoid.Model.Writing

  schema "readings" do
    field :author, :string
    field :description, :string
    field :publication_info, :string
    field :title, :string

    has_many :quotes, Writing.Quote
    # Delete:
    # Repo.delete(reading) will delete PersonalityReading, too (, if preloaded?)
    has_many :personalities, Writing.PersonalityRole,
      on_replace: :delete, on_delete: :delete_all, foreign_key: :reading_id

    timestamps()
  end

  @doc false
  def changeset(reading, attrs) do
    reading
    |> cast(attrs, [:title, :description, :author, :publication_info])
    |> add_personalities(attrs)
    |> validate_required([:title])
  end

  defp add_personalities(reading, %{ "personalities" => personalities }), do: put_assoc(reading, :personalities, personalities)
  defp add_personalities(reading, _), do: reading
end
