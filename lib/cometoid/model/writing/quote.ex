defmodule Cometoid.Model.Writing.Quote do
  use Ecto.Schema
  import Ecto.Changeset

  alias Cometoid.Model.Writing

  schema "quotes" do
    field :content, :string
    field :page_nr, :integer
    field :alt_page_nr, :string

    belongs_to :reading, Writing.Reading

    timestamps()
  end

  @doc false
  def changeset(quote_, attrs) do
    quote_
    |> cast(attrs, [:content, :page_nr, :alt_page_nr])
    |> add_reading(attrs)
    |> validate_required([:content])
  end

  defp add_reading(quote_, %{ "reading" => reading }), do: put_assoc(quote_, :reading, reading)
  defp add_reading(quote_, _), do: quote_
end
