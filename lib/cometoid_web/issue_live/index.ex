defmodule CometoidWeb.IssueLive.Index do
  use CometoidWeb.IssueLive.WrapHandle

  alias Cometoid.Repo.Tracker
  alias Cometoid.Repo.People
  alias Cometoid.Model.People.Person
  alias Cometoid.Model.Tracker.Issue
  alias Cometoid.Model.Tracker.Context
  alias CometoidWeb.Theme
  alias CometoidWeb.IssueLive
  alias CometoidWeb.IssueLive.IssuesMachine

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

    selected_view = get_selected_view params

    state = %{
      q: "",
      control_pressed: false,
      context_search_active: false,
      issue_search_active: false,
      list_issues_done_instead_open: false,
      sort_issues_alphabetically: false,
      selected_secondary_contexts: [],
      selected_view: selected_view
    }
    state = IssuesMachine.init_context_properties state
    state = IssuesMachine.set_issue_properties state 

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
    if (length socket.assigns.state.issues) == 1 do
      socket
      |> assign_state(:selected_issue, List.first socket.assigns.state.issues)
    else
      socket
    end
    |> assign_state(:issue_search_active, false)
  end

  def handle_info {:q, q}, socket do
    socket
    |> assign_state(:q, q)
    |> refresh_issues
  end

  def handle_info {:select_secondary_contexts, selected_secondary_contexts}, socket do
    socket
    |> assign_state(:selected_secondary_contexts, selected_secondary_contexts)
    |> assign(:modal, :keep)
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
          control_pressed: control_pressed
        } = state
      }
    } = socket do

    cond do
      key == "Control" && !state.context_search_active ->
        assign_state(socket, :control_pressed, true)
      state.issue_search_active or state.context_search_active ->
        case key do
          "Escape" ->
            socket
            |> assign_state(:context_search_active, false)
            |> assign_state(:issue_search_active, false)
            |> assign_state(:q, "")
            |> refresh_issues
          "," -> 
            if control_pressed do
              handle_suggestion_back socket, state
            else
              socket
            end
          "." -> 
            if control_pressed do
              handle_suggestion_forward socket, state
            else
              socket
            end
          _ -> 
            socket
        end
      not state.control_pressed ->
        case key do
          "Escape" -> handle_escape socket
          "n" ->
            if state.selected_context do
              socket
              |> assign(:modal, :new)
              |> assign_state(:issue, %Issue{})
            else
              socket
            end
          "h" ->
            if state.selected_context do
              socket
              |> assign(:modal, :filter_secondary_contexts)
            else
              socket
            end
          "e" ->
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
          "c" ->
            socket |> assign_state(:context_search_active, true)
          "i" ->
            assign_state(socket, :issue_search_active, true)
          "d" ->
            handle_describe socket
          _ ->
            socket
        end
      true -> socket
    end
  end

  def handle_event("keydown", _params, socket), do: socket

  def handle_event "keyup", %{ "key" => key }, 
    %{ assigns: %{ modal: modal, state: state }} = socket do

    case key do
      "Control" ->
        socket
        |> assign_state(:control_pressed, false)
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
    |> refresh_issues
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
    |> set_selected_issue(id)
    |> assign(:modal, :link_issue)
  end

  def handle_event "link_issue_to_issues", %{ "target" => id }, socket do
    socket
    |> set_selected_issue(id)
    |> assign(:modal, :link_issue_to_issues)
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
    |> assign_state(:issue_search_active, false)
    |> push_event(:issue_refocus, %{ id: target_issue_id })
    |> push_event(:context_refocus, %{ id: target_context_id })
    |> refresh_issues
  end

  def handle_event "select_previous_context", _, socket do

    state = IssuesMachine.select_previous_context (to_state socket)

    socket
    |> assign_state(state)
    |> push_event(:context_refocus, %{ id: state.selected_context.id })
  end

  def handle_event "create_new_context", %{ "view" => view }, socket do # TODO why is view passed?

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
    |> select_context(to_int id)
    |> assign(:modal, :link_context)
  end

  def handle_event "reprioritize_context", %{ "id" => id }, socket do

    id = to_int id
    state =
      socket.assigns.state
      |> IssuesMachine.select_context!(id)

    socket
    |> assign_state(state)
    |> assign_state(:context_search_active, false)
    |> push_event(:context_refocus, %{ id: state.selected_context.id })
    |> refresh_issues
  end

  def handle_event "toggle_context_important", %{ "target" => id }, socket do

    context = Tracker.get_context! id
    socket = socket |> assign_state(:selected_context, context)
    Tracker.update_context(context, %{ "important" => !context.important })

    socket
    |> assign_state(IssuesMachine.set_context_properties_and_keep_selected_context(to_state socket))
    |> assign_state(:context_search_active, false)
    |> push_event(:context_refocus, %{ id: id })
    |> refresh_issues
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

  def handle_event "show_open_issues", _params, socket do
    socket
    |> assign_state(:list_issues_done_instead_open, false)
    |> refresh_issues
  end

  def handle_event "show_closed_issues", _params, socket do
    socket
    |> assign_state(:list_issues_done_instead_open, true)
    |> refresh_issues
  end

  def handle_event "select_issue", %{ "target" => id }, socket do
    select_issue socket, id
  end

  def handle_event "reprioritize_issue", %{ "id" => id }, socket do
    Tracker.get_issue!(id)
    |> Tracker.update_issue_updated_at
    selected_issue = Tracker.get_issue! id
    socket
    |> assign_state(:issue_search_active, false)
    |> assign_state(:selected_issue, selected_issue)
    |> refresh_issues
  end

  def handle_event "toggle_issue_important", %{ "target" => id }, socket do

    selected_issue = Tracker.get_issue! id
    Tracker.update_issue2(selected_issue, %{ "important" => !selected_issue.important })

    socket
    |> assign_state(IssuesMachine.set_context_properties_and_keep_selected_context(to_state socket))
    |> assign_state(:selected_issue, selected_issue)
    |> assign_state(:issue_search_active, false)
    |> push_event(:issue_refocus, %{ id: id })
    |> refresh_issues
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
      unless (is_nil state.selected_context) do
        socket
        |> assign_state(:selected_context, nil)
        |> assign_state(:selected_contexts, [])
        |> refresh_issues
      else
        socket
        |> assign_state(:selected_issue, nil)
      end
      |> refresh_issues
      |> assign_state(:q, "")
    end
  end

  defp handle_suggestion_back socket, state do
    selected_issue = if state.selected_issue do
      {_item, index} = state.issues
        |> Enum.with_index()
        |> Enum.find(fn {%{id: id}, _index} -> id == state.selected_issue.id end)

      if index - 1 >= 0 do
        Enum.at state.issues, index - 1
      else
        state.selected_issue
      end
    else
      nil
    end
    socket
    |> assign_state(:selected_issue, selected_issue)
  end

  defp handle_suggestion_forward socket, state do
    selected_issue = if is_nil(state.selected_issue) 
      or (state.selected_issue.id not in (Enum.map state.issues, &(&1.id))) do

        List.first state.issues
      else
        {_item, index} = state.issues
          |> Enum.with_index()
          |> Enum.find(fn {%{id: id}, _index} -> id == state.selected_issue.id end)

        if index + 1 < length state.issues do
          Enum.at state.issues, index + 1
        else
          state.selected_issue
        end
      end
    socket
    |> assign_state(:selected_issue, selected_issue)
  end

  ## ISSUES_MACHINE - wraps and decorates calls to IssuesMachine

  defp refresh_issues %{ assigns: %{ state: state }} = socket do
    socket
    |> assign_state(IssuesMachine.refresh_issues state)
    |> assign(:modal, nil)
  end

  defp select_context %{ assigns: %{ state: state }} = socket, id do
    socket
    |> assign_state(IssuesMachine.select_context state, id)
  end

  defp select_context_and_refocus %{ assigns: %{ state: state }} = socket, id do
    if state.context_search_active do
      socket
      |> push_event(:context_refocus, %{ id: id })
    else
      socket
    end
    |> assign_state(IssuesMachine.select_context state, id)
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

  defp set_selected_issue socket, id do
    socket
    |> assign_state(:selected_issue, Tracker.get_issue!(id))
  end

  defp delete_issue %{ assigns: %{ state: state }} = socket, id do
    IssuesMachine.delete_issue state, id
    socket
  end

  # defp reprioritize_context socket do
    # state = to_state socket
    # unless is_nil state.selected_context do
      # socket
      # |> push_event(:context_refocus, %{ id: state.selected_context.id })
    # else
      # socket
    # end
  # end

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
    
    socket = if socket.assigns.state.issue_search_active do 
      socket
      |> push_event(:issue_refocus, %{ id: id })  
    else
      socket
    end
    
    socket
    |> assign_state(:selected_issue, selected_issue)
    |> assign_state(:issue_search_active, false)
    |> assign_state(:q, "")
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
