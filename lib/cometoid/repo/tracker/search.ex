defmodule Cometoid.Repo.Tracker.Search do

  import Ecto.Query, warn: false
  alias Cometoid.Repo
  alias Cometoid.Model.Tracker.Context
  alias Cometoid.Model.Tracker.Issue

  def list_contexts view do
    Context
    |> where([c], c.view == ^view)
    |> order_by([c], [{:desc, c.important}, {:desc, c.updated_at}])
    |> Repo.all
    |> do_context_preload
  end

  def list_contexts do
    Repo.all(from c in Context,
      order_by: [desc: :important, desc: :updated_at])
    |> do_context_preload
  end

  def list_issues query do

    issues = load_issues query

    if is_nil(query.selected_context) 
      or is_nil(query.selected_context.search_mode) 
      or query.selected_context.search_mode == 0 do

      issues
    else
      sort_issues issues, query
    end
  end

  def list_contexts view, q do
    Context
    |> where([c], c.view == ^view)
    |> search1(q)
    |> order_by([c], [{:desc, c.important}, {:desc, c.updated_at}])
    |> Repo.all
    |> do_context_preload
  end

  def do_context_preload context do # TODO review; duplicate with &Tracker.do_context_preload/1
    context
    |> Repo.preload(person: :birthday)
    |> Repo.preload(:text)
    |> Repo.preload(issues: :issue)
    |> Repo.preload(:secondary_contexts)
  end

  defp load_issues query do
    issues_query =
      Issue
      |> join(:left, [i], context_relation in assoc(i, :contexts))
      |> join(:left, [i, context_relation], context in assoc(context_relation, :context))
      |> where_type(query)
      |> search(query)
      |> order_issues(query)

    Repo.all(issues_query)
      |> Enum.uniq #?
      |> do_issues_preload
  end

  defp search issues_query, query do

    if query.search.q == "" do
      issues_query
    else
      q = query.search.q 
        |> String.split(" ")
        |> Enum.filter(&(&1 != ""))
        |> Enum.map(&("#{&1}:*"))
        |> Enum.join(" & ")
      issues_query
        |> where(
          [i,_,_],
          fragment("? @@ to_tsquery('simple', ?)",
            i.searchable, ^q))
    end
  end

  # TODO review, deduplicate with search
  defp search1 contexts_query, q do

    if q == "" do
      contexts_query
    else
      q = q 
        |> String.split(" ")
        |> Enum.filter(&(&1 != ""))
        |> Enum.map(&("#{&1}:*"))
        |> Enum.join(" & ")
      contexts_query
        |> where(
          [i,_,_],
          fragment("? @@ to_tsquery('simple', ?)",
            i.searchable, ^q))
    end
  end

  defp sort_issues issues, query do
    issues = issues
        |> Enum.filter(fn i -> not is_nil(i.short_title) end)
        |> Enum.map(fn i ->
          x = case Integer.parse(i.short_title) do
            :error -> {-1, ""}
            x -> x
          end
          {x, i} end)

    numeric =
      issues
      |> Enum.filter(fn {{_n, rest}, _i} -> rest == "" end)
      |> Enum.sort_by(fn {{n, _rest}, _i} -> n end, if query.selected_context.search_mode == 1 do :asc else :desc end)
      |> Enum.map(fn {{_s, _rest}, i} -> i end)

    non_numeric =
      issues
      |> Enum.filter(fn {{_s, rest}, _i} -> rest != "" end)
      |> Enum.sort_by(fn {{_s, _rest}, i} -> i.short_title end, if query.selected_context.search_mode == 1 do :asc else :desc end)
      |> Enum.map(fn {{_s, _rest}, i} -> i end)

    if query.selected_context.search_mode == 1 do
      non_numeric ++ numeric
    else
      numeric ++ non_numeric
    end
  end

  defp order_issues(query, %{ sort_issues_alphabetically: sort_issues_alphabetically }) do
    if sort_issues_alphabetically do
      query
    else
      order_by(query, [i, _context_relation, _context, _it],
        [{:desc, i.important}, {:desc, i.updated_at}])
    end
  end

  defp where_type(query, %{
    search: %{
      q: q,
      show_all_issues: show_all_issues
    },
    selected_context: nil,
    selected_issue: selected_issue,
    selected_view: selected_view,
    list_issues_done_instead_open: list_issues_done_instead_open
    }) do
 
    selected_issue_id = if selected_issue do selected_issue.id else -1 end

    if q == "" and not show_all_issues do
      query
      |> where([i, _context_relation, context], (context.view == ^selected_view and
        (
          (context.important == true and i.done == ^list_issues_done_instead_open)
          or i.important == true
          or ^selected_issue_id == i.id
        )
      ))
    else
      query
      |> where([i, _context_relation, context], (context.view == ^selected_view
        and i.done == ^list_issues_done_instead_open))
    end
  end

  defp where_type(query, %{
      selected_context: selected_context,
      list_issues_done_instead_open: list_issues_done_instead_open
    }) do

    query
    |> where([i, _context_relation, context], context.id == ^selected_context.id
      and i.done == ^list_issues_done_instead_open)
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

  defp do_issues_preload issue do
    issue
    |> Repo.preload(contexts: :context)
    |> Repo.preload(:event)
    |> Repo.preload(:issues)
  end
end
