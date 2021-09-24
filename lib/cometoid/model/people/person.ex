defmodule Cometoid.Model.People.Person do
  use Ecto.Schema
  import Ecto.Changeset

  alias Cometoid.Model.Tracker
  alias Cometoid.Model.Calendar

  schema "persons" do
    field :name, :string
    field :description, :string

    belongs_to :context, Tracker.Context
    has_one :birthday, Calendar.Event, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(person, attrs) do
    person
    |> cast(attrs, [:name, :description])
    |> put_assoc_birthday(attrs)
    |> put_assoc_context(attrs)
    |> validate_required([:name])
  end

  def update_changeset(person, attrs) do
    person
    |> cast(attrs, [:name, :description])
    |> cast_assoc(:birthday, with: &Calendar.Event.date_changeset/2)
    |> cast_assoc(:context, with: &Tracker.Context.changeset/2)
    |> validate_required([:name])
  end

  defp put_assoc_birthday(person, %{ "birthday" => birthday }), do: put_assoc(person, :birthday, birthday)
  defp put_assoc_birthday(person, _), do: person

  defp put_assoc_context(person, %{ "context" => context }), do: put_assoc(person, :context, context)
  defp put_assoc_context(person, _), do: person
end
