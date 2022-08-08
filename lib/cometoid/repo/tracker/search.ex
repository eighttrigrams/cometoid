defmodule Cometoid.Repo.Tracker.Search do

  import Ecto.Query, warn: false
  import Cometoid.Repo.Shared
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

  def list_issues state do

    issues = load_issues state

    if is_nil(state.selected_context) 
      or is_nil(state.selected_context.search_mode) 
      or state.selected_context.search_mode == 0 do

      issues
    else
      sort_issues issues, state
    end
  end

  def list_contexts view, q do
    Context
    |> where([c], c.view == ^view)
    |> search(q)
    |> order_by([c], [{:desc, c.important}, {:desc, c.updated_at}])
    |> Repo.all
    |> do_context_preload
  end

  defp load_issues query do
    issues_query =
      Issue
      |> join(:left, [i], context_relation in assoc(i, :contexts))
      |> join(:left, [i, context_relation], context in assoc(context_relation, :context))
      |> where_type(query)
      |> search(query.search.q)
      |> order_issues(query)
  
    Repo.all(issues_query)
      |> Enum.uniq #?
      |> do_issues_preload
  end

  defp search query, q do

    if q == "" do
      query
    else
      q = q 
        |> String.split(" ")
        |> Enum.filter(&(&1 != ""))
        |> Enum.map(&("#{&1}:*"))
        |> Enum.join(" & ")
      query
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
      selected_secondary_contexts: selected_secondary_contexts,
      list_issues_done_instead_open: list_issues_done_instead_open
    }) do

    query
    |> where([i, _context_relation, context], context.id == ^selected_context.id
      and i.done == ^list_issues_done_instead_open)
    
    selected_secondary_contexts
    |> Enum.with_index
    |> Enum.reduce(query, fn arg, query -> 
      frags query, arg, (length selected_secondary_contexts) 
    end)
  end

  defp frag q, arg do
    q
    |> where([i, _context_relation, _context],
      fragment("EXISTS (
      SELECT *
      FROM contexts, issues, context_issue
      WHERE issues.id = ?
      AND context_issue.context_id = contexts.id 
      AND context_issue.issue_id = issues.id
      AND contexts.id = ?
      )", i.id, ^arg))  
  end

  defp frags query, {arg, index}, l do
    cond do
      index == 0 and l > 1 -> 
        query
        |> where([i, _context_relation, _context], fragment("(TRUE"))
        |> frag(arg)
      index == l - 1 and l > 1 ->
        query
        |> frag(arg)
        |> where([i, _context_relation, _context], fragment("TRUE)"))
      true -> 
        query
        |> frag(arg)
    end
  end
end
