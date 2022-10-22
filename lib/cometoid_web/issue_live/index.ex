defmodule CometoidWeb.IssueLive.Index do
  use CometoidWeb.IssueLive.WrapHandle

  import CometoidWeb.IssueLive.KeysNav

  alias Cometoid.Repo.Tracker
  alias Cometoid.Repo.Tracker.Search
  alias Cometoid.Repo.People
  alias Cometoid.Model.People.Person
  alias Cometoid.Model.Tracker.Issue
  alias Cometoid.Model.Tracker.Context
  alias Cometoid.State.IssuesMachine
  alias CometoidWeb.Theme
  alias CometoidWeb.IssueLive

  @impl true
  def mount _params, _session, socket do
    {
      :ok,
      socket
      |> assign(Theme.get)
      |> assign(:state, %{})
      |> assign(:modal, nil)
      |> assign(:handler, nil)
    }
  end

  @impl true
  def handle_params params, _url, socket do

    state = params
      |> get_selected_view
      |> IssuesMachine.State.new
      |> put_in([:modifiers], MapSet.new())
      |> IssuesMachine.init_context_properties
      |> IssuesMachine.set_issue_properties

    socket
    |> assign_state(state)
    |> assign_state(:view, params["view"])
    |> refresh_issues
  end

  ## HANDLE_INFO

  @impl true
  def handle_info {:modal_closed}, socket do
    socket
  end

  def handle_info {:select_context, id}, socket do
    select_context_and_refocus socket, id
  end

  def handle_info {:select_issue}, socket do
    handle_confirm_issue_search socket
  end

  def handle_info {:select_context}, socket do
    handle_confirm_context_search socket
  end

  def handle_info {:search_issues, :q, q}, socket do
    socket
    |> assign_state([:search, :q], q)
    |> refresh_issues
  end

  def handle_info {:search_contexts, :q, q}, socket do
    socket
    |> assign_state([:search, :q], q)
    |> refresh_contexts
  end

  def handle_info {:select_secondary_contexts, selected_secondary_contexts}, socket do
    socket
    |> assign_state(:selected_secondary_contexts, selected_secondary_contexts)
    |> assign(:modal, :keep)
    |> refresh_issues
  end

  def handle_info {:after_edit_form_save, %{ context_id: context_id }}, socket do
    socket
    |> reload_changed_context(context_id)
    |> push_event(:context_refocus, %{ id: context_id })
    |> refresh_issues
  end

  def handle_info {:after_edit_form_save, issue}, socket do
    socket
    |> set_context_properties_and_keep_selected_context
    |> assign_state(:selected_issue, issue)
    |> refresh_issues
  end

  ## HANDLE_EVENT

  @impl true
  def handle_event "keydown", %{ "key" => key }, 
    %{ assigns: 
      %{ 
        modal: nil,
        state: %{
          modifiers: modifiers,
          selected_issue: selected_issue,
          search: %{
            context_search_active: context_search_active,
            issue_search_active: issue_search_active
          }
        } = state
      }
    } = socket do

    cond do
      key == "Control" -> assign_state socket, :modifiers, MapSet.put(modifiers, :ctrl)
      key == "Meta" -> assign_state socket, :modifiers, MapSet.put(modifiers, :meta)
      key == "Alt" -> assign_state socket, :modifiers, MapSet.put(modifiers, :alt)
      modifiers == MapSet.new([:ctrl, :meta, :alt]) ->
        case key do
          "," -> handle_reprioritize_issue_and_select_next socket
          _ -> socket
        end
      modifiers == MapSet.new([:ctrl, :meta]) -> 
        case key do
          "," -> handle_reprioritize socket
          "." -> handle_important socket
          _ -> socket
        end
      modifiers == MapSet.new([:ctrl]) ->
        case key do 
          "," -> if context_search_active or ((is_nil selected_issue) and not issue_search_active) do
              select_previous_context socket
            else
              select_previous_issue socket
            end
          "." -> if context_search_active or ((is_nil selected_issue) and not issue_search_active) do
              select_next_context socket
            else
              select_next_issue socket
            end
          "m" -> if not context_search_active and is_nil selected_issue do
              select_next_issue socket
            else
              socket
            end
          _ -> socket
        end  
      issue_search_active or context_search_active ->
        case key do
          "Escape" ->
            handle_quit_search socket
          _ -> 
            socket
        end
      true ->
        case key do
          "Escape" -> handle_escape socket
          "n" -> handle_new_issue socket
          "h" -> handle_show_secondary_contexts socket
          "l" -> handle_link socket
          "e" -> handle_edit socket
          "c" -> handle_context_search socket
          "i" -> handle_issue_search socket
          "d" -> handle_describe socket
          _ -> socket
        end
    end
  end

  def handle_event("keydown", _params, socket), do: socket

  def handle_event "keyup", %{ "key" => key }, 
    %{ 
      assigns: %{ 
        modal: modal, 
        state: %{ modifiers: modifiers } = state
      }
    } = socket do

    case key do
      "Control" -> assign_state socket, :modifiers, MapSet.delete(modifiers, :ctrl)
      "Meta" -> assign_state socket, :modifiers, MapSet.delete(modifiers, :meta)
      "Alt" -> assign_state socket, :modifiers, MapSet.delete(modifiers, :alt)
      "h" ->
        if state.selected_context && modal == :filter_secondary_contexts do
          socket
          |> assign(:modal, nil)
        else
          socket
        end
      _ ->
        socket
    end
  end

  def handle_event "switch-theme", %{ "name" => _name }, socket do
    Theme.toggle!
    socket
    |> assign(Theme.get)
  end

  def handle_event "delete_issue", %{ "id" => id }, socket do
    socket
    |> delete_issue(id)
  end

  def handle_event "deselect_selected_contexts", _params, socket do
    socket
    |> assign_state(:selected_secondary_contexts, [])
    |> refresh_issues
  end

  def handle_event "edit_issue", id, socket do
    id = to_int id
    socket
    |> assign_state(:issue, Tracker.get_issue!(id))
    |> assign(:modal, :edit_issue)
  end

  def handle_event "link_issue", %{ "target" => id }, socket do
    socket
    |> link_issue(Tracker.get_issue!(id))
  end

  def handle_event "convert_issue_to_context", %{ "id" => id }, socket do

    id = to_int id
    state = IssuesMachine.convert_issue_to_context(socket.assigns.state, id)

    socket
    |> assign_state(state)
  end

  def handle_event "edit_issue_description", _, socket do
    socket
    |> edit_issue_description(socket.assigns.state.selected_issue.id)
  end

  def handle_event "create_new_issue", _params, socket do
    socket
    |> assign_state(:issue, %Issue{})
    |> assign(:modal, :new)
  end

  def handle_event "jump_to_issue", %{ "target_issue_id" => target_issue_id }, socket do
    
    target_issue_id = to_int target_issue_id
    issue = Tracker.get_issue! target_issue_id

    socket
    |> assign_state(:selected_context, nil)
    |> assign_state(:selected_issue, issue)
    |> push_event(:issue_refocus, %{ id: target_issue_id })
    |> refresh_issues
  end

  def handle_event "jump_to_context",
      %{
        "target_context_id" => target_context_id,
        "target_issue_id" => target_issue_id
      },
      socket do

    target_context_id = to_int target_context_id
    target_issue_id = to_int target_issue_id

    state = IssuesMachine.jump_to_context socket.assigns.state,
      target_context_id, target_issue_id

    socket
    |> assign_state(state)
    |> assign_state([:search, :issue_search_active], false)
    |> push_event(:issue_refocus, %{ id: target_issue_id })
    |> push_event(:context_refocus, %{ id: target_context_id })
    |> refresh_issues
  end

  def handle_event "create_new_context", %{ "view" => view }, socket do

    entity = case view do
      "People" -> %Person{}
      _ -> %Context{}
    end

    socket
    |> assign_state(:edit_entity, entity)
    |> assign(:modal, :new_context)
    |> assign_state(:edit_selected_view, view)
  end

  def handle_event "delete_context", %{ "id" => id }, socket do

    state = IssuesMachine.delete_context to_state(socket), id
    socket
    |> assign_state(state)
  end

  def handle_event "right_click", _, socket do
    socket
    |> assign_state(:control_pressed, true)
  end

  def handle_event "mouse_leave", _, socket do
    socket
    |> assign_state(:control_pressed, false)
  end

  def handle_event "edit_context_description", _, socket do
    socket
    |> edit_context_description(socket.assigns.state.selected_context.id)
  end

  def handle_event "edit_context", id, socket do

    id = to_int id
    socket
    |> edit_context(id)
  end

  def handle_event "select_context", %{ "id" => id }, socket do

    id = to_int id
    select_context_and_refocus socket, id
  end

  def handle_event "link_context", %{ "id" => id }, socket do
    socket
    |> link_context(to_int id)
  end

  def handle_event "reprioritize_context", %{ "id" => id }, socket do
    id = to_int id
    reprioritize_context socket, id
  end

  def handle_event "toggle_context_important", %{ "target" => id }, socket do
    toggle_context_important socket, id
  end

  def handle_event "toggle_sort", _params, socket do
    selected_context =
      socket.assigns.state.selected_context

    new_search_mode = unless is_nil(selected_context.search_mode) do
      rem(selected_context.search_mode + 1, 3)
    else
      1
    end
    {:ok, selected_context} = Tracker.update_context selected_context, %{ "search_mode" => new_search_mode }
    socket
    |> assign_state(:selected_context, selected_context)
    |> refresh_issues
  end

  def handle_event "select_issue", %{ "target" => id }, socket do
    select_issue socket, id
  end

  def handle_event "reprioritize_issue", %{ "id" => id }, socket do
    reprioritize_issue socket, id
  end

  def handle_event "toggle_issue_important", %{ "target" => id }, socket do
    toggle_issue_important socket, id
  end

  def handle_event "unarchive", %{ "target" => id }, socket do
    socket
    |> assign_state(IssuesMachine.unarchive_issue((to_state socket), id))
    |> push_event(:issue_refocus, %{ id: id })
  end

  def handle_event "archive", %{ "target" => id }, socket do
    socket
    |> assign_state(IssuesMachine.archive_issue((to_state socket), id))
  end

  ## PUBLIC - functions called from templates

  def was_last_called_handler_select_context? handler do
    handler == "select_context"
  end

  ## KEY_HANDLERS

  defp handle_new_issue socket do
    state = to_state socket
    if state.selected_context do
      socket
      |> assign(:modal, :new)
      |> assign_state(:issue, %Issue{})
    else
      socket
    end
  end

  defp handle_show_secondary_contexts socket do
    state = to_state socket
    if state.selected_context do
      socket
      |> assign(:modal, :filter_secondary_contexts)
    else
      socket
    end
  end

  defp handle_link socket do
    state = to_state socket
    if state.selected_context do
      if state.selected_issue do
        link_issue socket, state.selected_issue
      else
        link_context socket, state.selected_context.id
      end
    else
      socket
    end
  end
  
  defp handle_context_search socket do
    state = to_state socket
    socket 
    |> assign_state([:search, :context_search_active], true)
    |> assign_state([:search, :previously_selected_context], state.selected_context)
  end
  
  defp handle_issue_search socket do
    state = to_state socket
    socket
    |> assign_state([:search, :issue_search_active], true)
    |> assign_state([:search, :previously_selected_context], state.selected_context)
    |> assign_state([:search, :previously_selected_issue], state.selected_issue)
  end

  defp handle_edit socket do
    state = to_state socket
    cond do
      not is_nil(state.selected_issue) ->
        id = state.selected_issue.id
        socket
        |> assign_state(:issue, (Tracker.get_issue! id))
        |> assign(:modal, :edit_issue)
      not is_nil(state.selected_context) ->
        id = state.selected_context.id
        edit_context socket, id
      true -> socket
    end
  end

  defp handle_important socket do
    state = to_state socket
    if state.selected_issue do
      toggle_issue_important socket, state.selected_issue.id
    else
      if state.selected_context do
        toggle_context_important socket, state.selected_context.id
      else
        socket
      end
    end
  end

  defp handle_reprioritize_issue_and_select_next socket do
    reprioritize_issue_and_select_next socket
  end

  defp handle_reprioritize socket do
    state = to_state socket
    if state.selected_issue do
      reprioritize_issue socket, state.selected_issue.id
    else
      if state.selected_context do
        reprioritize_context socket, state.selected_context.id
      else
        socket
      end
    end
  end

  defp handle_describe socket do
    state = to_state socket
    if state.selected_issue do
      edit_issue_description socket, state.selected_issue.id
    else
      if state.selected_context do
        edit_context_description socket, state.selected_context.id
      else
        socket
      end
    end
  end

  defp handle_escape socket do
    state = to_state socket
    unless state.selected_secondary_contexts == [] do
      socket
      |> assign_state(:selected_secondary_contexts, [])
    else
      if state.selected_issue do
        socket
        |> assign_state(:selected_issue, nil)
      else
        socket
        |> assign_state(:selected_context, nil)
        |> assign_state(:selected_contexts, [])
      end
    end
    |> refresh_issues
    |> assign_state(:q, "")
  end

  defp handle_confirm_issue_search %{ assigns: %{ state: state }} = socket do
    if (length socket.assigns.state.issues) != 0 do
      selected_issue = case (length socket.assigns.state.issues) do
          0 -> nil
          1 -> List.first socket.assigns.state.issues
          _ -> socket.assigns.state.selected_issue
        end

      socket
      |> assign_state(:selected_issue, selected_issue)
      |> push_event(:issue_refocus, %{ id: selected_issue.id })
    else
      socket
      |> assign_state(:selected_issue, state.search.previously_selected_issue)
    end
    |> assign_state([:search, :issue_search_active], false)
    |> assign_state([:search, :q], "")
    |> refresh_issues
  end

  defp handle_confirm_context_search %{ assigns: %{ state: state }} = socket do
    if (length socket.assigns.state.contexts) != 0 do
      selected_context = case (length socket.assigns.state.contexts) do
          0 -> nil
          1 -> List.first socket.assigns.state.contexts
          _ -> socket.assigns.state.selected_context
        end

      socket
      |> assign_state(:selected_context, selected_context)
      |> push_event(:context_refocus, %{ id: selected_context.id })
    else
      socket
      |> assign_state(:selected_context, state.search.previously_selected_context)
    end
    |> assign_state([:search, :context_search_active], false)
    |> assign_state([:search, :q], "")
    |> refresh_contexts
    |> refresh_issues
  end

  defp handle_quit_search %{ assigns: %{ state: state }} = socket do

    socket
    |> assign_state([:search, :context_search_active], false)
    |> assign_state([:search, :issue_search_active], false)
    |> assign_state([:search, :q], "")
    |> assign_state(:selected_issue, state.search.previously_selected_issue)
    |> assign_state(:selected_context, state.search.previously_selected_context)
    |> refresh_issues
    |> refresh_contexts
  end

  def select_previous_context %{ assigns: %{ state: state }} = socket do
    selected_context = get_previous_context state
    socket
    |> assign_state(:selected_context, selected_context)
    |> push_event(:context_refocus, %{ id: selected_context.id })
    |> refresh_issues
  end  

  def select_next_context %{ assigns: %{ state: state }} = socket do
    selected_context = get_next_context state
    socket
    |> assign_state(:selected_context, selected_context)
    |> push_event(:context_refocus, %{ id: selected_context.id })
    |> refresh_issues
  end

  def select_previous_issue %{ assigns: %{ state: state }} = socket do
    selected_issue = get_previous_issue state
    socket
    |> assign_state(:selected_issue, selected_issue)
    |> push_event(:issue_refocus, %{ id: selected_issue.id })
  end

  def select_next_issue %{ assigns: %{ state: state }} = socket do
    selected_issue = get_next_issue state
    socket
    |> assign_state(:selected_issue, selected_issue)
    |> push_event(:issue_refocus, %{ id: selected_issue.id })
  end

  ## ISSUES_MACHINE - wraps and decorates calls to IssuesMachine

  defp toggle_issue_important socket, id do
    selected_issue = Tracker.get_issue! id
    Tracker.update_issue2(selected_issue, %{ "important" => !selected_issue.important })

    socket
    |> assign_state(IssuesMachine.set_context_properties_and_keep_selected_context(to_state socket))
    |> assign_state(:selected_issue, selected_issue)
    |> assign_state([:search, :issue_search_active], false)
    |> push_event(:issue_refocus, %{ id: id })
    |> refresh_issues
  end
  
  defp toggle_context_important socket, id do
    context = Tracker.get_context! id
    socket = socket |> assign_state(:selected_context, context)
    Tracker.update_context(context, %{ "important" => !context.important })

    socket
    |> assign_state(IssuesMachine.set_context_properties_and_keep_selected_context(to_state socket))
    |> assign_state([:search, :context_search_active], false)
    |> push_event(:context_refocus, %{ id: id })
    |> refresh_issues
  end

  defp reprioritize_issue_and_select_next socket do
    state = to_state socket
    Tracker.update_issue_updated_at state.selected_issue

    selected_issue = get_next_issue state
    socket
    |> assign_state(:selected_issue, selected_issue)
    |> push_event(:issue_refocus, %{ id: selected_issue.id })
    |> refresh_issues
  end
  
  defp reprioritize_issue socket, id do
    Tracker.get_issue!(id)
    |> Tracker.update_issue_updated_at
    selected_issue = Tracker.get_issue! id
    socket
    |> assign_state([:search, :issue_search_active], false)
    |> assign_state(:selected_issue, selected_issue)
    |> refresh_issues
  end
  
  defp reprioritize_context socket, id do
    state =
      socket.assigns.state
      |> IssuesMachine.select_context!(id)

    socket
    |> assign_state(state)
    |> assign_state([:search, :context_search_active], false)
    |> push_event(:context_refocus, %{ id: state.selected_context.id })
    |> refresh_issues
  end

  defp refresh_issues %{ assigns: %{ state: state }} = socket do
    socket
    |> assign_state(IssuesMachine.refresh_issues state)
    |> assign(:modal, nil)
  end

  defp refresh_contexts %{ assigns: %{ state: state }} = socket do
    contexts = Search.list_contexts state.view, state.search.q

    selected_context = if not is_nil(state.selected_context) 
      and state.selected_context.id in (Enum.map contexts, &(&1.id)) do
      
        state.selected_context
      end

    socket
    |> assign_state(:contexts, contexts)
    |> assign_state(:selected_context, selected_context)
  end

  defp select_context_and_refocus %{ assigns: %{ state: state }} = socket, id do
    if state.search.context_search_active do
      socket
      |> push_event(:context_refocus, %{ id: id })
    else
      socket
    end
    |> assign_state(IssuesMachine.select_context state, id)
    |> refresh_contexts
  end

  defp reload_changed_context %{ assigns: %{ state: state }} = socket, context_id do
    state = IssuesMachine.reload_changed_context state, context_id
    socket
    |> assign_state(state)
  end

  defp set_context_properties_and_keep_selected_context %{ 
    assigns: %{ state: state }} = socket do

    state = IssuesMachine.set_context_properties_and_keep_selected_context state
    socket
    |> assign_state(state)
  end

  defp link_issue socket, issue do
    socket
    |> assign_state(:selected_issue, issue)
    |> assign(:modal, :link_issue)
  end

  defp link_context %{ assigns: %{ state: state }} = socket, id do
    socket
    |> assign_state(IssuesMachine.select_context state, id)
    |> assign(:modal, :link_context)
  end

  defp delete_issue %{ assigns: %{ state: state }} = socket, id do
    state = IssuesMachine.delete_issue state, id
    socket
    |> assign_state(state)
  end

  ## ECTO

  defp edit_issue_description socket, id do
    socket
    |> assign_state(:issue, Tracker.get_issue!(id))
    |> assign(:modal, :describe)
  end

  defp edit_context socket, id do
    context = Tracker.get_context! id
    entity = case context.view do
      "People" -> People.get_person! context.person.id
      _ -> context
    end

    socket
    |> assign_state(:edit_selected_view, context.view)
    |> assign_state(:edit_entity, entity)
    |> assign(:modal, :edit_context)
  end

  defp edit_context_description socket, id do
    context = Tracker.get_context! id
    entity = case context.view do
      "People" -> People.get_person! context.person.id
      _ -> context
    end
    socket
    |> assign_state(:edit_entity, entity)
    |> assign(:modal, :describe_context)
  end

  defp select_issue socket, id do
    selected_issue = Tracker.get_issue! id
    
    socket = if socket.assigns.state.search.issue_search_active do 
      socket
      |> push_event(:issue_refocus, %{ id: id })  
    else
      socket
    end
    
    socket
    |> assign_state(:selected_issue, selected_issue)
    |> assign_state([:search, :issue_search_active], false)
    |> assign_state([:search, :q], "")
    |> refresh_issues
  end

  ## HELPER

  defp get_selected_view params do
    if Map.has_key?(params, "view") do
      params["view"]
    end
  end

  defp to_state(socket), do: socket.assigns.state
end
