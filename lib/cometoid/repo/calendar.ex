defmodule Cometoid.Repo.Calendar do
  @moduledoc """
  The Calendar context.
  """

  import Ecto.Query, warn: false
  alias Cometoid.Repo

  alias Cometoid.Model.Calendar.Event

  def list_events archived do

    if archived == true do
      Repo.all(from e in Event,
        where: e.archived == true,
        order_by: [desc: e.date])
    else
      Repo.all(from e in Event,
        where: e.archived == false,
        order_by: [asc: e.date])
    end
    |> Repo.preload(:issue)
    |> Repo.preload(:person)
  end

  def get_event!(id) do
    Repo.get!(Event, id)
    |> Repo.preload(:issue)
    |> Repo.preload(:person)
  end

  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end

  def update_event(%Event{} = event, attrs) do

    if not is_nil(event.person_id) or not is_nil(event.issue_id) do
      Event.date_changeset(event, attrs)
    else
      Event.changeset(event, attrs)
    end
    |> Repo.update()
  end

  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  def change_event(%Event{} = event, attrs \\ %{}) do
    Event.changeset(event, attrs)
  end
end
