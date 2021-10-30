defmodule Cometoid.Repo.Tracker do
  @moduledoc """
  The Tracker context.
  """

  import Ecto.Query, warn: false
  alias Cometoid.Repo
  alias Cometoid.Model.Tracker.Relation
  alias Cometoid.Model.Tracker.Context
  alias Cometoid.Model.Calendar
  alias Cometoid.Model.Tracker.Issue

  def get_contexts_by_titles titles do
    Context
    |> where([c], c.title in ^titles)
    |> Repo.all
  end

  def list_contexts(context_type_title) do
    Context
    |> where([c], c.context_type == ^context_type_title)
    |> order_by([c], [{:desc, c.important}, {:desc, c.updated_at}])
    |> Repo.all
    |> Repo.preload(:person)
    |> Repo.preload(:text)
    |> Repo.preload(:children)
  end

  def list_contexts do
    Repo.all(from c in Context,
      order_by: [desc: :important, desc: :updated_at])
    |> Repo.preload(issues: :issue)
    |> Repo.preload(person: :birthday)
    |> Repo.preload(:text)
    |> Repo.preload(:children)
  end

  def get_context!(id) do
    Repo.get!(Context, id)
    |> Repo.preload(person: :birthday)
    |> Repo.preload(:text)
    |> Repo.preload(issues: :issue)
    |> Repo.preload(:children)
  end

  def create_context(attrs, selected_context_type) do

    attrs = put_in(attrs["context_type"], selected_context_type)

    %Context{}
    |> Context.changeset(attrs)
    |> Repo.insert()
  end

  def update_context(%Context{} = context, attrs) do
    context
    |> Context.changeset(attrs)
    |> Repo.update()
  end

  def update_context_updated_at(context) do
    context
    |> Context.changeset(%{})
    |> Repo.update(force: true)
  end

  def delete_context(%Context{} = context) do

    issue_ids = Enum.map(context.issues, &(&1.id))
    Repo.delete(context)
    Enum.map(issue_ids, fn issue_id ->
      issue = get_issue!(issue_id)
      if issue.contexts == [], do: Repo.delete(issue)
    end)
    {:ok, 1}
  end

  def change_context(%Context{} = context, attrs \\ %{}) do
    Context.changeset(context, attrs)
  end

  defmodule Query do
    defstruct selected_context: nil, # required
      list_issues_done_instead_open: false
  end

  def list_issues(query) do
    query =
      Issue
      |> join(:left, [i], c in assoc(i, :contexts))
      |> join(:left, [i, c], cc in assoc(c, :context))
      |> where_type(query)
      |> order_by([i, _c, _cc, _it], [{:desc, i.important}, {:desc, i.updated_at}])

      Repo.all(query)
      |> Repo.preload(contexts: :context)
      |> Repo.preload(:event)
  end

  defp where_type(query, %{
      selected_context: selected_context,
      list_issues_done_instead_open: list_issues_done_instead_open
    }) do
    query
    |> where([i, _c, cc], cc.id == ^selected_context.id and i.done == ^list_issues_done_instead_open)
  end

  def get_issue!(id) do
    Repo.get!(Issue, id)
    |> Repo.preload(contexts: :context)
    |> Repo.preload(:event)
  end

  def create_issue(title, context) do
    {:ok, issue} = Repo.insert(%Issue{
      title: title,
      contexts: [%{ context: context }]
    })
    {:ok, Repo.preload(issue, :event)}
  end

  def update_issue_relations issue, selected_contexts, contexts do

    context_from =  fn title -> Enum.find contexts, &(&1.title == title) end
    ctxs = Enum.map(selected_contexts, context_from)
      |> Enum.map(fn ctx -> %{ context: ctx } end)

    issue
    |> Issue.relations_changeset(%{ "contexts" => ctxs })
    |> Repo.update
  end

  def update_issue %Issue{} = issue, attrs, contexts do

    attrs = unless is_nil(attrs["contexts"]) do
      context_from = fn title -> Enum.find contexts, &(&1.title == title) end
      put_in(attrs["contexts"], Enum.map(attrs["contexts"], context_from))
    else
      attrs
    end

    if not is_nil(issue.event) and is_nil(attrs["event"]) do
      Issue.delete_event_changeset(issue, attrs)
    else
      Issue.changeset(issue, attrs)
    end
    |> Repo.update
  end

  def update_issue_description issue, attrs do
    issue
    |> Issue.description_changeset(attrs)
    |> Repo.update
  end

  def update_issue2(issue, attrs) do
    changeset = Issue.changeset(issue, attrs)
    |> Repo.update
  end

  def update_issue_updated_at(issue) do
    issue
    |> Issue.changeset(%{})
    |> Repo.update(force: true)
  end

  def delete_issue(%Issue{} = issue) do
    Repo.delete(issue)
  end

  def change_issue(%Issue{} = issue, attrs \\ %{}) do
    Issue.changeset(issue, attrs)
  end
end
