defmodule Cometoid.Model.Calendar.Event do
  use Ecto.Schema
  import Ecto.Changeset

  alias Cometoid.Model.Tracker
  alias Cometoid.Model.People

  schema "events" do
    field :date, :date
    field :title, :string
    field :archived, :boolean, default: false

    belongs_to :issue, Tracker.Issue
    belongs_to :person, People.Person

    timestamps()
  end

  @doc false
  def changeset event, attrs do
    event
    |> cast(attrs, [:title, :date, :archived])
    |> validate_required([:title, :date])
  end

  def date_changeset event, attrs do
    event
    |> cast(attrs, [:date, :archived])
    |> validate_required([:date])
  end
end
