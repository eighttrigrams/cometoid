defmodule Cometoid.State.IssuesMachine do

  defmodule State do
    def new view do
      %{
        sort_issues_alphabetically: nil,
        selected_view: view,
        selected_issue: nil,
        selected_context: nil,
        selected_secondary_contexts: [],
        search: %{
          q: "",
          show_all_issues: false,
          context_search_active: false,
          issue_search_active: false,
          previously_selected_issue: nil,
          previously_selected_context: nil
        }
      }
    end
  end

  use Cometoid.State.Machine

  alias Cometoid.Repo.Tracker
  alias Cometoid.Repo.Tracker.Search

  def set_issue_properties(state, selected_issue \\ nil)

  def set_issue_properties(
      %{ selected_context: selected_context } = state,
      selected_issue) when not is_nil(selected_context) do

    _get_rid_of_warning = selected_context

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
      :refresh_issues,
      state
      |> init_context_properties
      |> set_issue_properties
    }
  end

  def init_context_properties state do
    %{
      selected_context: nil,
      selected_contexts: [],
      contexts: (load_contexts_for_view state)
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
    contexts = load_contexts_for_view state

    %{
      selected_context: selected_context,
      contexts: contexts
    }
  end

  @doc """
  Makes the context fetched by id the new selected_context.
  Pushes the id to the stack of recently selected_contexts.
  Deselects selected_issue.

  ## Examples

    iex> select_context old_state, some_context_id
    new_state

  """
  def select_context state, id do

    selected_context = Tracker.get_context! id

    selected_contexts = case state.selected_contexts do
      [previous_context_id|_] -> if previous_context_id == selected_context.id do
        state.selected_contexts
      else
        [selected_context.id|state.selected_contexts]
      end
      [] -> [selected_context.id]
    end

    state = (State.new state.selected_view)
      |> put_in([:selected_context], selected_context)
      |> put_in([:selected_contexts], selected_contexts)

    {:refresh_issues, state}
  end

  def jump_to_context state, target_context_id, target_issue_id do
    target_issue = Tracker.get_issue! target_issue_id
    target_context = Tracker.get_context! target_context_id
    contexts = if target_context.view != state.selected_view do
      load_contexts_for_view Map.merge state, %{ selected_view: target_context.view }
    else
      state.contexts
    end
    {:refresh_issues, %{
        contexts: contexts,
        selected_context: target_context,
        selected_issue: target_issue,
        control_pressed: false,
        selected_view: target_context.view
    }}
  end

  def convert_issue_to_context state, id do
    _context = Tracker.convert_issue_to_context id, state.selected_view
    contexts = load_contexts_for_view state
    {:refresh_issues, %{
      contexts: contexts
    }}
  end

  def archive_issue state, id do
    issue = Tracker.get_issue! id
    Tracker.update_issue2(issue, %{ "done" => true, "important" => false })

    selected_issue = determine_selected_issue state, id
    new_state = Map.merge(
      (set_context_properties_and_keep_selected_context state),
      %{ selected_issue: selected_issue })

    {:refresh_issues, new_state}
  end

  def unarchive_issue state, id do
    issue = Tracker.get_issue! id
    Tracker.update_issue2(issue, %{ "done" => false })

    new_state = Map.merge(
      (set_context_properties_and_keep_selected_context state),
      %{
        selected_issue: issue
      })

    {:refresh_issues, new_state}
  end

  def delete_issue state, id do
    issue = Tracker.get_issue! id
    {:ok, _} = Tracker.delete_issue issue

    state = if is_nil state.selected_context do
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
    {:refresh_issues, state}
  end

  def refresh_issues state do
    do_query_refresh_issues state
  end

  defp do_query_refresh_issues state do
    issues = Search.list_issues state
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
    Search.list_contexts()
    |> Enum.filter(&(&1.view == selected_view))
  end
end
