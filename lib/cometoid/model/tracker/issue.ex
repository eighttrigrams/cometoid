defmodule Cometoid.Model.Tracker.Issue do
  use Ecto.Schema
  import Ecto.Changeset

  alias Cometoid.Model.Tracker.Relation
  alias Cometoid.Model.Calendar

  schema "issues" do
    field :description, :string
    field :done, :boolean, default: false
    field :title, :string
    field :short_title, :string
    field :important, :boolean, default: false

    has_many(
      :contexts,
      Relation,
      on_replace: :delete,
      on_delete: :delete_all
    )

    has_one :event, Calendar.Event, on_replace: :delete, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(issue, attrs) do
    issue
    |> cast(attrs, [:title, :short_title, :description, :done, :important])
    |> cast_assoc_event(attrs)
    |> validate_required([:title, :done])
  end

  def description_changeset(issue, attrs) do
    issue
    |> cast(attrs, [:description])
  end

  def relations_changeset(issue, attrs) do
    issue
    |> cast(attrs, [])
    |> put_assoc_contexts(attrs)
  end

  def delete_event_changeset(issue, attrs) do
    issue
    |> cast(attrs, [:title, :short_title,:description, :done, :important])
    |> put_assoc_contexts(attrs)
    |> put_assoc(:event,
      %{ Calendar.Event.date_changeset(issue.event, %{}) | action: :delete })
    |> validate_required([:title, :done])
  end

  defp put_assoc_contexts(issue, %{ "contexts" => contexts }), do: put_assoc(issue, :contexts, contexts)
  defp put_assoc_contexts(issue, _), do: issue

  defp cast_assoc_event(issue, %{ "event" => _event }), do: cast_assoc(issue, :event, with: &Calendar.Event.date_changeset/2)
  defp cast_assoc_event(issue, _), do: issue
end
