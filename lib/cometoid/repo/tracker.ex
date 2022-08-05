defmodule Cometoid.Repo.Tracker do
  @moduledoc """
  The Tracker context.
  """

  import Ecto.Query, warn: false
  import Cometoid.Repo.Shared
  alias Cometoid.Repo
  alias Cometoid.Repo.Tracker.Search
  alias Cometoid.Model.Tracker.Context
  alias Cometoid.Model.Tracker.Issue

  def get_context! id do
    Repo.get!(Context, id)
    |> do_context_preload
  end

  def convert_issue_to_context id, view do
    issue = get_issue! id
    secondary_contexts_ids = Enum.map issue.contexts, fn r ->
      r.context.id
    end
    {:ok, context} = create_context %{
      "title" => issue.title,
      "description" => issue.description,
      "view" => view }
    {:ok, context} = context
      |> do_context_preload
      |> link_contexts(secondary_contexts_ids)

    delete_issue issue
    context
  end

  @doc """

  Does not link secondary_contexts.
  Use `link_contexts` instead

  ## Examples

    iex> create_context %{ "title" => title, "view" => view }

  """
  def create_context attrs do
    {:ok, context} = %Context{}
      |> Context.changeset(attrs)
      |> Repo.insert
    {:ok, do_context_preload(context)}
  end

  def update_context %Context{} = context, attrs do
    context
    |> Context.changeset(attrs)
    |> Repo.update()
  end

  def update_context_updated_at context do
    context
    |> Context.changeset(%{})
    |> Repo.update(force: true)
  end

  @doc """
  Requires the primary_context's secondary_contexts to be preloaded
  Returns {:ok, context}
  """
  def link_contexts primary_context, secondary_contexts_ids do

    secondary_contexts = get_contexts_by_ids secondary_contexts_ids
    result =
      primary_context
      |> Context.link_contexts_changeset(%{ "secondary_contexts" => secondary_contexts})
      |> Repo.update()

    link_secondary_contexts secondary_contexts, primary_context

    ids_of_contexts_where_links_should_be_removed
      = Enum.map(primary_context.secondary_contexts, &(&1.id))
      -- secondary_contexts_ids

    unlink_secondary_contexts ids_of_contexts_where_links_should_be_removed, primary_context.id

    result
  end

  @doc """
  Requires the primary_issues's connected_issues to be preloaded
  Returns {:ok, issue}
  """
  def link_issues primary_issue, connected_issues_ids do

    connected_issues = get_issues_by_ids connected_issues_ids
    result =
      primary_issue
      |> Issue.link_issues_changeset(%{ "issues" => connected_issues})
      |> Repo.update()

    link_connected_issues connected_issues, primary_issue

    ids_of_issues_where_links_should_be_removed
      = Enum.map(primary_issue.issues, &(&1.id))
      -- connected_issues_ids

    unlink_connected_issues ids_of_issues_where_links_should_be_removed, primary_issue.id

    result
  end

  def delete_context %Context{} = context do

    issue_ids = Enum.map context.issues, &(&1.issue.id)

    Enum.map issue_ids, fn issue_id ->
      issue = get_issue! issue_id

      context_ids =
        issue.contexts
        |> Enum.filter(&((context.is_tag? && &1.context.id == context.id) || !&1.context.is_tag?))
        |> Enum.map(&(&1.context.id))

      if context_ids == [context.id] do
        link_issues issue, []
        Repo.delete issue
      end
    end

    secondary_contexts_ids = Enum.map context.secondary_contexts, &(&1.id)
    unlink_secondary_contexts secondary_contexts_ids, context.id

    Repo.delete get_context! context.id
    {:ok, 1}
  end

  defp unlink_secondary_contexts ids_of_contexts_where_links_should_be_removed, primary_context_id do
    contexts_where_links_should_be_removed
      = get_contexts_by_ids ids_of_contexts_where_links_should_be_removed

    Enum.map contexts_where_links_should_be_removed, fn context_where_links_should_be_removed ->

      context_where_links_should_be_removed
        = Repo.preload context_where_links_should_be_removed, :secondary_contexts

      contexts = Enum.filter context_where_links_should_be_removed.secondary_contexts,
        &(&1.id != primary_context_id)

      context_where_links_should_be_removed
        |> Context.link_contexts_changeset(
          %{ "secondary_contexts" =>
            contexts
          }
        )
        |> Repo.update()
    end
  end

  def change_context %Context{} = context, attrs \\ %{} do
    Context.changeset(context, attrs)
  end

  def get_issue! id do
    Repo.get!(Issue, id)
    |> do_issues_preload
  end

  def create_issue! title, short_title, contexts do
    {:ok, issue} = create_issue title, short_title, contexts
    issue
  end

  def create_issue title, short_title, contexts do
    {:ok, issue} = Repo.insert(%Issue{
      title: title,
      short_title: short_title,
      contexts: Enum.map(contexts, &(%{ context: &1 }))
    })
    {:ok, do_issues_preload(issue)}
  end

  def remove_issue_relation issue, id_of_context_to_be_unlinked do

    ctxs = Enum.filter issue.contexts,
      fn relation ->
        relation.context.id != id_of_context_to_be_unlinked
      end

    issue
    |> Issue.relations_changeset(%{ "contexts" => ctxs })
    |> Repo.update!
    |> do_issues_preload
  end

  def update_issue_relations issue, ids_of_selected_contexts do

    context_from =  fn id -> Enum.find Search.list_contexts(), &(&1.id == id) end
    contexts =
      ids_of_selected_contexts
      |> Enum.map(context_from)
      |> Enum.map(fn ctx -> %{ context: ctx } end)

    issue
    |> Issue.relations_changeset(%{ "contexts" => contexts })
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

  def update_issue2 issue, attrs do
    Issue.changeset(issue, attrs)
    |> Repo.update
  end

  def update_issue_updated_at(issue) do
    issue
    |> Issue.changeset(%{})
    |> Repo.update(force: true)
  end

  def delete_issue(%Issue{} = issue) do
    link_issues issue, []
    Repo.delete(issue)
  end

  def change_issue(%Issue{} = issue, attrs \\ %{}) do
    Issue.changeset(issue, attrs)
  end

  defp unlink_connected_issues ids_of_contexts_where_links_should_be_removed, primary_context_id do
    contexts_where_links_should_be_removed
      = get_issues_by_ids ids_of_contexts_where_links_should_be_removed

    Enum.map contexts_where_links_should_be_removed, fn context_where_links_should_be_removed ->

      context_where_links_should_be_removed
        = Repo.preload context_where_links_should_be_removed, :issues

      contexts = Enum.filter context_where_links_should_be_removed.issues,
        &(&1.id != primary_context_id)

      context_where_links_should_be_removed
        |> Issue.link_issues_changeset(
          %{ "issues" =>
            contexts
          }
        )
        |> Repo.update()
    end
  end

  defp link_secondary_contexts secondary_contexts, primary_context do
    Enum.map secondary_contexts, fn secondary_context ->
      secondary_context = Repo.preload secondary_context, :secondary_contexts
      secondary_contexts_reverse_ids = Enum.map secondary_context.secondary_contexts, &(&1.id)
      unless primary_context.id in secondary_contexts_reverse_ids do
        secondary_context
        |> Context.link_contexts_changeset(
          %{ "secondary_contexts" =>
            [primary_context|secondary_context.secondary_contexts]
          }
        )
        |> Repo.update()
      end
    end
  end

  defp link_connected_issues secondary_contexts, primary_context do
    Enum.map secondary_contexts, fn secondary_context ->
      secondary_context = Repo.preload secondary_context, :issues
      secondary_contexts_reverse_ids = Enum.map secondary_context.issues, &(&1.id)
      unless primary_context.id in secondary_contexts_reverse_ids do
        secondary_context
        |> Issue.link_issues_changeset(
          %{ "issues" =>
            [primary_context|secondary_context.issues]
          }
        )
        |> Repo.update()
      end
    end
  end

  defp get_contexts_by_ids ids do
    Context
    |> where([c], c.id in ^ids)
    |> Repo.all
  end

  defp get_issues_by_ids ids do
    Issue
    |> where([c], c.id in ^ids)
    |> Repo.all
  end
end
