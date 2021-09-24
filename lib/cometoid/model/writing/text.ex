defmodule Cometoid.Model.Writing.Text do
  use Ecto.Schema
  import Ecto.Changeset

  alias Cometoid.Model.Tracker

  schema "texts" do
    field :audience, :string
    field :description, :string
    field :title, :string
    field :type, :string

    belongs_to :context, Tracker.Context

    timestamps()
  end

  @doc false
  def changeset(text, attrs) do
    text
    |> cast(attrs, [:title, :description, :type, :audience])
    |> put_assoc_context(attrs)
    |> validate_required([:title])
  end

  def update_changeset(text, attrs) do
    text
    |> cast(attrs, [:title, :description, :type, :audience])
    |> cast_assoc(:context, with: &Tracker.Context.changeset/2)
    |> validate_required([:title])
  end

  defp put_assoc_context(text, %{ "context" => context }), do: put_assoc(text, :context, context)
  defp put_assoc_context(text, _), do: text
end
