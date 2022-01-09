defmodule CometoidWeb.IssueLive.IssuesMachine do
  use CometoidWeb.IssueLive.Machine

  alias Cometoid.Repo.Tracker

  def set_issue_properties(state, selected_issue \\ nil)

  def set_issue_properties(
      %{ selected_context: selected_context } = state,
      selected_issue) when not is_nil(selected_context) do

    Map.merge state, %{
      selected_issue: selected_issue
    }
  end

  def set_issue_properties(
      state,
      _) do
    %{
      selected_issue: nil
    }
  end

  def reload_changed_context state, id do
    selected_context = Tracker.get_context! id # fetch latest important flag
    state
    |> Map.merge(%{ selected_context: selected_context })
    |> set_context_properties_and_keep_selected_context
    |> set_issue_properties
  end

  def delete_context state, id do
    context = Tracker.get_context!(id)
    {:ok, _} = Tracker.delete_context(context)

    {
      :do_query,
      state
      |> init_context_properties
      |> set_issue_properties
    }
  end

  def init_context_properties state do
    contexts = load_contexts_for_view state
    %{
      selected_context: nil,
      selected_contexts: [],
      contexts: contexts
    }
  end

  def set_context_properties_and_keep_selected_context state do
    contexts = load_contexts_for_view state
    selected_context = unless is_nil state.selected_context do
      Tracker.get_context! state.selected_context.id
    end
    %{
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
  def select_context! state, id do

    selected_context = Enum.find(state.contexts, &(&1.id == id))
    Tracker.update_context_updated_at selected_context
    contexts = load_contexts_for_view state # TODO review duplication with init_context_properties

    %{
      selected_context: selected_context,
      contexts: contexts
    }
  end

  @doc """

  ## Examples

    iex> select_context old_state, some_context_id
    new_state

  """
  def select_context state, id do

    selected_context = Tracker.get_context! id
    selected_issue = keep_issue state, selected_context
    selected_contexts = case state.selected_contexts do
      [previous_context_id|_] -> if previous_context_id == selected_context.id do
        state.selected_contexts
      else
        [selected_context.id|state.selected_contexts]
      end
      [] -> [selected_context.id]
    end
    %{
      selected_context: selected_context,
      selected_contexts: selected_contexts,
      selected_issue: selected_issue
    }
  end

  @doc """
  TODO rename: it is used for jumping to context with (!) an issue

  Call do_query after this, to reload all issues for the current context                TODO
  """
  def jump_to_context state, target_context_id, target_issue_id do
    target_issue = Tracker.get_issue! target_issue_id
    target_context = Tracker.get_context! target_context_id
    selected_contexts = [target_context.id|state.selected_contexts] # TODO only do if we are in some context
    %{
        selected_context: target_context,
        selected_contexts: selected_contexts,
        selected_issue: target_issue,
        control_pressed: false
    }
  end

  def select_previous_context state do
   result = with [_selected_context_id, previous_context_id|rest]
                                    <- state.selected_contexts,
         selected_context           <- (Tracker.get_context! previous_context_id),
         selected_issue             <- (keep_issue state, selected_context) do
      %{
        selected_context: selected_context,
        selected_contexts: [previous_context_id|rest],
        selected_issue: selected_issue,
      }
    else
      [] -> %{}
      [_|_] -> %{}
    end
    {:do_query, result}
  end

  def unlink_issue state, id do

    issue = id
      |> Tracker.get_issue!
      |> Tracker.remove_issue_relation(state.selected_context.id)

    state = if has_one_non_tag_context? issue do
      select_context state, (first_non_tag_context issue).id
    else
      %{
        selected_context: nil
      }
    end

    Map.merge state, %{
      selected_issue: issue
    }
  end

  def archive_issue state, id do
    issue = Tracker.get_issue! id
    Tracker.update_issue2(issue, %{ "done" => true, "important" => false })

    selected_issue = determine_selected_issue state, id
    new_state = Map.merge(
      set_context_properties_and_keep_selected_context(state),
      %{ selected_issue: selected_issue })

    {:do_query, new_state}
  end

  def unarchive_issue state, id do
    issue = Tracker.get_issue! id
    Tracker.update_issue2(issue, %{ "done" => false })

    new_state = %{
      list_issues_done_instead_open: false,
      selected_issue: issue
    }

    {:do_query, new_state}
  end

  def delete_issue state, id do
    issue = Tracker.get_issue! id
    {:ok, _} = Tracker.delete_issue issue

    if is_nil state.selected_context do
      %{
        selected_issue: nil
      }
    else
      selected_context = Tracker.get_context! state.selected_context.id # fetch latest issues
      selected_issue = determine_selected_issue state, id
      %{
        selected_context: selected_context,
        selected_issue: selected_issue
      }
    end
  end

  def do_query state do
    do_the_query state
  end

  defp do_the_query state do
    query = %Tracker.Query{
      list_issues_done_instead_open: state.list_issues_done_instead_open,
      selected_context: state.selected_context,
      selected_view: state.selected_view
    }
    issues = Tracker.list_issues query # TODO review if passing state; or to use map take
    %{ issues: issues }
  end

  defp keep_issue state, selected_context do
    unless is_nil state.selected_issue do
      case Enum.find selected_context.issues, &(&1.issue.id == state.selected_issue.id) do
        nil -> nil
        relation -> relation.issue
      end
    end
  end

  defp determine_selected_issue state, id do
    selected_issue = state.selected_issue
    if not is_nil(selected_issue)
      and Integer.to_string(selected_issue.id) != id do selected_issue end
  end

  defp load_contexts_for_view %{ selected_view: selected_view } = _state do
    Tracker.list_contexts()
    |> Enum.filter(&(&1.view == selected_view))
  end

  defp has_one_non_tag_context? issue do
    1 == length Enum.filter issue.contexts, &(!&1.context.is_tag?)
  end

  # Expects there to be at least one.
  defp first_non_tag_context issue do
    (Enum.find issue.contexts, &(!&1.context.is_tag?)).context
  end
end
