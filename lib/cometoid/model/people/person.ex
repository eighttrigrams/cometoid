defmodule Cometoid.Model.People.Person do
  use Ecto.Schema
  import Ecto.Changeset

  alias Cometoid.Model.Tracker
  alias Cometoid.Model.Calendar

  schema "persons" do
    field :name, :string
    field :description, :string

    belongs_to :context, Tracker.Context
    has_one :birthday, Calendar.Event, on_replace: :delete, on_delete: :delete_all

    field :original_birthday, :date, source: :birthday

    field :use_birthday, :boolean

    timestamps()
  end

  @doc false
  def changeset person, attrs do
    person
    |> cast(attrs, [:name, :description])
    |> put_assoc_birthday(attrs)
    |> put_assoc_context(attrs)
    |> validate_required([:name])
  end

  def update_changeset person, attrs do
    person
    |> cast(attrs, [:name, :description, :original_birthday, :use_birthday])
    |> cast_assoc(:birthday, with: &Calendar.Event.date_changeset/2)
    |> cast_assoc(:context, with: &Tracker.Context.changeset/2)
    |> validate_required([:name])
  end

  def delete_birthday_changeset person, attrs do # TODO review
    person
    |> cast(attrs, [:name, :description, :original_birthday, :use_birthday])
    |> cast_assoc(:context, with: &Tracker.Context.changeset/2)
    |> put_assoc(:birthday,
      %{ Calendar.Event.date_changeset(person.birthday, %{}) | action: :delete })
    |> validate_required([:name])
  end

  def update_description_changeset person, attrs do
    person
    |> cast(attrs, [:description])
  end

  defp put_assoc_birthday(person, %{ "birthday" => birthday }), do: put_assoc(person, :birthday, birthday)
  defp put_assoc_birthday(person, _), do: person

  defp put_assoc_context(person, %{ "context" => context }), do: put_assoc(person, :context, context)
  defp put_assoc_context(person, _), do: person
end
