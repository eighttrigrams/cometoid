defmodule Cometoid.Model.Tracker.Issue do
  use Ecto.Schema
  import Ecto.Changeset

  alias Cometoid.Model.Tracker.Relation
  alias Cometoid.Model.Calendar

  schema "issues" do
    field :description, :string
    field :title, :string
    field :short_title, :string
    field :important, :boolean, default: false
    field :tags, :string, default: ""

    has_many(
      :contexts,
      Relation,
      on_replace: :delete,
      on_delete: :delete_all
    )

    has_one :event, Calendar.Event, on_replace: :delete, on_delete: :delete_all

    many_to_many :issues,
      Cometoid.Model.Tracker.Issue,
      join_through: "issue_issue",
      join_keys: [left_id: :id, right_id: :id],
      on_replace: :delete,
      on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(issue, attrs) do
    issue
    |> cast(attrs, [:title, :short_title, :description, :important, :tags])
    |> cast_assoc_event(attrs)
    |> validate_required([:title])
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
    |> cast(attrs, [:title, :short_title,:description, :done, :important, :tags])
    |> put_assoc_contexts(attrs)
    |> put_assoc(:event,
      %{ Calendar.Event.date_changeset(issue.event, %{}) | action: :delete })
    |> validate_required([:title, :done])
  end

  def link_issues_changeset issue, attrs do
    issue
    |> cast(attrs, [])
    |> put_assoc_issues(attrs)
  end

  defp put_assoc_issues(issue, %{ "issues" => issues }), do: put_assoc(issue, :issues, issues)
  defp put_assoc_issues(issue, _), do: issue

  defp put_assoc_contexts(issue, %{ "contexts" => contexts }), do: put_assoc(issue, :contexts, contexts)
  defp put_assoc_contexts(issue, _), do: issue

  defp cast_assoc_event(issue, %{ "event" => _event }), do: cast_assoc(issue, :event, with: &Calendar.Event.date_changeset/2)
  defp cast_assoc_event(issue, _), do: issue
end
