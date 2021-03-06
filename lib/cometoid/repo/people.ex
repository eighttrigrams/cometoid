defmodule Cometoid.Repo.People do
  @moduledoc """
  The People context.
  """

  import Ecto.Query, warn: false
  alias Cometoid.Repo
  alias Cometoid.Model.Calendar
  alias Cometoid.Model.Tracker
  alias Cometoid.Model.People.Person

  def list_persons do
    Repo.all(Person)
    |> Repo.preload(:context)
    |> Repo.preload(:birthday)
  end

  def get_person!(id) do
    Repo.get!(Person, id)
    |> Repo.preload(:context)
    |> Repo.preload(:birthday)
  end

  def create_person(attrs \\ %{}) do

    birthday_changeset = %Calendar.Event{}
      |> Calendar.Event.date_changeset(attrs["birthday"])

    context_changeset = %Tracker.Context{}
      |> Tracker.Context.changeset(%{ "view" => "People", "title" => attrs["name"] })

    attrs = put_in(attrs["birthday"], birthday_changeset)
    attrs = put_in(attrs["context"], context_changeset)

    {
      :ok,
      %Person{}
      |> Person.changeset(attrs)
      |> Repo.insert!
      |> Repo.preload(:context)
      |> Repo.preload(:birthday)
    }
  end

  def update_person(%Person{} = person, attrs) do

    attrs = put_in(attrs["context"],
      %{ "title" => attrs["name"], "id" => person.context.id })

    {:ok, if not is_nil(person.birthday) and is_nil(attrs["birthday"]) do
        Person.delete_birthday_changeset(person, attrs)
      else
        Person.update_changeset(person, attrs)
      end
      |> Repo.update!
      |> Repo.preload(:context)
      |> Repo.preload(:birthday)
    }
  end

  def update_person_description(%Person{} = person, attrs) do
    {
      :ok,
      person
      |> Person.update_description_changeset(attrs)
      |> Repo.update!
      |> Repo.preload(:context)
      |> Repo.preload(:birthday)
    }
  end

  def change_person_description(%Person{} = person, attrs \\ %{}) do
    Person.update_description_changeset(person, attrs)
  end

  def change_person(%Person{} = person, attrs \\ %{}) do
    Person.changeset(person, attrs)
  end
end
