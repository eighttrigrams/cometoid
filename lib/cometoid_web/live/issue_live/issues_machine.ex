defmodule CometoidWeb.IssueLive.IssuesMachine do

  import Cometoid.Utils
  alias Cometoid.Repo.Tracker

  def set_issue_properties(
      %{ selected_context: selected_context } = state,
      selected_issue \\ nil) when not is_nil(selected_context) do

    issue_types = get_issue_types selected_context
    selected_issue_type = get_selected_issue_type issue_types

    issue_properties = %{
      issue_types: issue_types,
      selected_issue_type: selected_issue_type,
      selected_issue: selected_issue
    }

    state
    |> Map.merge(issue_properties)
    |> Map.delete(:flash)
  end

  def set_issue_properties(
      state,
      _) do

    issue_properties = %{
      issue_types: [],
      selected_issue_type: nil,
      selected_issue: nil
    }

    state
    |> Map.merge(issue_properties)
    |> Map.delete(:flash)
  end

  @doc """

  ## Params

  context_types: can be nil # TODO really, why?

  """
  def set_context_properties state, select_from_first_group do
    {important, others} = contexts = reload_contexts state

    selected_context = List.first(
      if select_from_first_group and (length(important) > 0) do
        important
      else
        others
      end
    )

    Map.merge state, %{
      selected_context: selected_context,
      contexts: contexts
    }
  end

  def set_context_properties state do
    {important, others} = contexts = reload_contexts state

    selected_context = Tracker.get_context!(state.selected_context.id)

    Map.merge state, %{
      selected_context: selected_context,
      contexts: contexts
    }
  end

  @doc """

  ## Side effects

  Updates updated_at of context

  ## Examples

    iex> select_context old_state, "some_context_title"
    new_state

  """
  def select_context! state, context do

    selected_context =
      elem(state.contexts, 0) ++ elem(state.contexts, 1)
      |> Enum.find(&(&1.title == context))

    Tracker.update_context_updated_at selected_context
    set_context_properties state, selected_context.important
  end

  @doc """

  ## Examples

    iex> select_context old_state, "some_context_title"
    new_state

  """
  def select_context state, context do

    selected_context =
      elem(state.contexts, 0) ++ elem(state.contexts, 1)
      |> Enum.find(&(&1.title == context))

    Map.merge state, %{
      selected_context: selected_context
    }
  end

  def archive_issue state, id do
    issue = Tracker.get_issue! id
    Tracker.update_issue2(issue, %{ "done" => true, "important" => false })

    selected_issue = determine_selected_issue state, id
    Map.merge(set_context_properties(state), %{ selected_issue: selected_issue })
  end

  def delete_issue state, id do
    issue = Tracker.get_issue! id
    {:ok, _} = Tracker.delete_issue issue

    selected_context = Tracker.get_context! state.selected_context.id # fetch latest issues
    selected_issue = determine_selected_issue state, id
    Map.merge state, %{
      selected_context: selected_context,
      selected_issue: selected_issue
    }
  end

  def do_query(%{ selected_context: selected_context } = state) when is_nil(selected_context) do
    Map.merge state, %{
      issues: {[], []}
    }
  end

  def do_query state  do
    query = %Tracker.Query{
      list_issues_done_instead_open: state.list_issues_done_instead_open,
      selected_issue_type: state.selected_issue_type,
      selected_context: state.selected_context
    }
    issues =
      query
      |> Tracker.list_issues
      |> separate(&(&1.important == true))

    Map.merge state, %{
      issues: issues
    }
  end

  defp determine_selected_issue state, id do
    selected_issue = state.selected_issue
    if not is_nil(selected_issue)
      and Integer.to_string(selected_issue.id) != id do selected_issue end
  end

  defp get_selected_issue_type issue_types do
    if length(issue_types) == 1, do: List.first issue_types
  end

  defp get_issue_types selected_context do
    Application.fetch_env!(:cometoid, :issue_types)[selected_context.context_type]
  end

  defp reload_contexts %{ context_types: context_types, selected_context_type: selected_context_type } = state do
    contexts = unless is_nil(state.context_types) do
      Tracker.list_contexts()
      |> Enum.filter(fn context -> if is_nil(selected_context_type) do context.context_type in context_types else context.context_type == selected_context_type end end)
    else
      Tracker.list_contexts()
    end
    |> separate(&(&1.important == true))
  end
end
