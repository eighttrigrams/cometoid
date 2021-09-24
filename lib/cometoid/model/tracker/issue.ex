defmodule Cometoid.Model.Tracker.Issue do
  use Ecto.Schema
  import Ecto.Changeset

  alias Cometoid.Model.Tracker.Context
  alias Cometoid.Model.Calendar

  schema "issues" do
    field :description, :string
    field :done, :boolean, default: false
    field :title, :string
    field :issue_type, :string
    field :important, :boolean, default: false
    field :markdown, :string
    field :has_markdown, :boolean, default: false

    many_to_many(
      :contexts,
      Context,
      join_through: "context_issue",
      on_replace: :delete,
      on_delete: :delete_all
    )

    has_one :event, Calendar.Event, on_replace: :delete, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(issue, attrs) do
    issue
    |> cast(attrs, [:title, :description, :done, :issue_type, :important, :has_markdown, :markdown])
    |> put_assoc_contexts(attrs)
    |> cast_assoc_event(attrs)
    |> validate_required([:title, :done])
  end

  def delete_event_changeset(issue, attrs) do
    issue
    |> cast(attrs, [:title, :description, :done, :issue_type, :important, :has_markdown, :markdown])
    |> put_assoc_contexts(attrs)
    |> put_assoc(:event,
      %{ Calendar.Event.date_changeset(issue.event, %{}) | action: :delete })
    |> validate_required([:title, :done])
  end

  defp put_assoc_contexts(issue, %{ "contexts" => contexts }), do: put_assoc(issue, :contexts, contexts)
  defp put_assoc_contexts(issue, _), do: issue

  defp cast_assoc_event(issue, %{ "event" => event }), do: cast_assoc(issue, :event, with: &Calendar.Event.date_changeset/2)
  defp cast_assoc_event(issue, _), do: issue
end
