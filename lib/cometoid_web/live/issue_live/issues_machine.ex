defmodule CometoidWeb.IssueLive.IssuesMachine do
  use CometoidWeb.IssueLive.DeleteFlash

  import Cometoid.Utils
  alias Cometoid.Repo.Tracker

  def set_issue_properties(
      %{ selected_context: selected_context } = state,
      selected_issue \\ nil) when not is_nil(selected_context) do

    issue_properties = %{
      selected_issue: selected_issue
    }
    state
    |> Map.merge(issue_properties)
  end

  def set_issue_properties(
      state,
      _) do

    issue_properties = %{
      selected_issue: nil
    }

    state
    |> Map.merge(issue_properties)
  end

  @doc """
  Call do_query after this, to reload all issues for the current context
  """
  def jump_to_context state, target_context_id, target_issue_id do
    target_issue = Tracker.get_issue! target_issue_id
    target_context = Tracker.get_context! target_context_id
    state
    |> Map.merge(%{
        selected_context: target_context,
        selected_issue: target_issue
      })
  end

  def set_context_properties state do
    contexts = reload_contexts state
    Map.merge state, %{
      selected_context: nil,
      contexts: contexts
    }
  end

  def set_context_properties_and_keep_selected_context state do
    contexts = reload_contexts state
    selected_context = unless is_nil state.selected_context do
      Tracker.get_context! state.selected_context.id
    end
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
    selected_context = Enum.find(state.contexts, &(&1.title == context))
    Tracker.update_context_updated_at selected_context
    contexts = reload_contexts state # TODO review duplication with set_context_properties
    Map.merge state, %{
      selected_context: selected_context,
      contexts: contexts
    }
  end

  @doc """

  ## Examples

    iex> select_context old_state, "some_context_title"
    new_state

  """
  def select_context state, context do

    selected_context = state.contexts |> Enum.find(&(&1.title == context))

    Map.merge state, %{
      selected_context: selected_context
    }
  end

  def archive_issue state, id do
    issue = Tracker.get_issue! id
    Tracker.update_issue2(issue, %{ "done" => true, "important" => false })

    selected_issue = determine_selected_issue state, id
    Map.merge(set_context_properties_and_keep_selected_context(state),
      %{ selected_issue: selected_issue })
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

  def do_query state  do
    query = %Tracker.Query{
      list_issues_done_instead_open: state.list_issues_done_instead_open,
      selected_context: state.selected_context,
      selected_view: state.selected_view
    }
    issues = Tracker.list_issues query # TODO review if passing state; or to use map take
    Map.merge state, %{ issues: issues }
  end

  defp determine_selected_issue state, id do
    selected_issue = state.selected_issue
    if not is_nil(selected_issue)
      and Integer.to_string(selected_issue.id) != id do selected_issue end
  end

  defp reload_contexts %{ selected_view: selected_view } = state do
    Tracker.list_contexts()
    |> Enum.filter(fn context -> context.view == selected_view end)
  end
end
