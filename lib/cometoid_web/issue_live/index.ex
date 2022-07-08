defmodule CometoidWeb.IssueLive.Index do
  use CometoidWeb, :live_view
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
    }
  end

  @impl true
  def handle_params params, _url, socket do

    selected_view = get_selected_view params

    state = %{
      control_pressed: false,
      context_search_active: false,
      issue_search_active: false,
      list_issues_done_instead_open: false,
      sort_issues_alphabetically: false,
      show_secondary_contexts_instead_issues: false,
      selected_secondary_contexts: [],
      selected_view: selected_view
    }
    state = IssuesMachine.init_context_properties state
    state = IssuesMachine.set_issue_properties state # TODO necessary? If yes, use at least the pipe operator

    socket = socket
      |> assign_state(state)
      |> assign_state(:live_action, socket.assigns.live_action) # TODO review

    socket
    |> assign(:view, params["view"])
    |> assign_state(:view, params["view"]) # TODO review
    |> do_query
    |> apply_action(socket.assigns.live_action, params) # TODO review
  end

  @impl true
  def handle_info {:modal_closed}, socket do
    socket = socket
    |> assign_state(:live_action, :index) # TODO assign to assigns directly, not to state
    socket
  end

  def handle_info {:select_context, id}, socket do
    select_context socket, id
  end

  def handle_info {:select_issue, id}, socket do
    select_issue socket, id
  end

  def handle_info {:select_secondary_contexts, selected_secondary_contexts}, socket do
    socket
    |> assign_state(:selected_secondary_contexts, selected_secondary_contexts)
  end

  def handle_info {:after_edit_form_save, %{ context_id: context_id }}, socket do
    state = IssuesMachine.reload_changed_context (to_state socket), context_id
    socket
    |> assign_state(state)
    |> push_event(:context_reprioritized, %{ id: context_id })
    |> do_query
  end

  def handle_info {:after_edit_form_save, issue}, socket do

    state =
      IssuesMachine.set_context_properties_and_keep_selected_context socket.assigns.state

    socket
    |> assign_state(state)
    |> assign_state(:selected_issue, issue)
    |> do_query
  end

  @impl true
  def handle_event "keydown", %{ "key" => key }, %{ assigns: %{ live_action: :index, state: state } } = socket do
    cond do
      key == "Control" && !state.context_search_active ->
        assign_state(socket, :control_pressed, true)
      state.issue_search_active or state.context_search_active ->
        case key do
          "Escape" ->
            socket
            |> assign_state(:context_search_active, false)
            |> assign_state(:issue_search_active, false)
          _ -> socket
        end
      not state.control_pressed ->
        case key do
          "Escape" -> handle_escape socket
          "n" ->
            if state.selected_context do
              socket
              |> assign_state(:live_action, :new)
              |> assign_state(:issue, %Issue{})
            else
              socket
            end
          "h" ->
            if state.selected_context do
              socket
              |> assign_state(:live_action, :filter_secondary_contexts)
            else
              socket
            end
          "e" ->
            cond do
              not is_nil(state.selected_issue) ->
                id = state.selected_issue.id
                socket
                |> assign_state(:issue, Tracker.get_issue!(id))
                |> assign_state(:live_action, :edit)
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

  def handle_event "keyup", %{ "key" => key }, socket do
    state = socket.assigns.state
    case key do
      "Control" ->
        socket
        |> assign_state(:control_pressed, false)
      "h" ->
        if state.selected_context && state.live_action == :filter_secondary_contexts do
          socket
          |> assign_state(:live_action, :index)
        else
          socket
        end
      _ ->
        socket
    end
    socket
  end

  def handle_event "switch-theme", %{ "name" => _name }, socket do
    Theme.toggle!
    socket
    |> assign(Theme.get)
  end

  def handle_event "delete_issue", %{ "id" => id }, socket do
    state = IssuesMachine.delete_issue (to_state socket), id
    socket
    |> assign_state(state)
    |> do_query
  end

  def handle_event "deselect_selected_contexts", _params, socket do
    socket
    |> assign_state(:selected_secondary_contexts, [])
    |> do_query
  end

  def handle_event "toggle_show_secondary_contexts_instead_issues", _params, socket do
    socket
    |> assign_state(:show_secondary_contexts_instead_issues,
      !socket.assigns.state.show_secondary_contexts_instead_issues)
  end

  def handle_event "edit_issue", id, socket do

    id = to_int id

    socket
    |> assign_state(:issue, Tracker.get_issue!(id))
    |> assign_state(:live_action, :edit)
  end

  def handle_event "link_issue", %{ "target" => id }, socket do
    socket
    |> assign_state(:selected_issue, Tracker.get_issue!(id))
    |> assign_state(:live_action, :link)
  end

  def handle_event "link_issue_to_issues", %{ "target" => id }, socket do
    socket
    |> assign_state(:selected_issue, Tracker.get_issue!(id))
    |> assign_state(:live_action, :link_issue_to_issues)
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
    |> assign_state(:live_action, :new)
  end

  def handle_event "jump_to_issue", %{ "target_issue_id" => target_issue_id }, socket do
    
    target_issue_id = to_int target_issue_id
    issue = Tracker.get_issue! target_issue_id

    socket
    |> assign_state(:selected_context, nil)
    |> assign_state(:selected_issue, issue)
    |> push_event(:issue_reprioritized, %{ id: target_issue_id })
    |> do_query
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
    |> push_event(:issue_reprioritized, %{ id: target_issue_id })
    |> push_event(:context_reprioritized, %{ id: target_context_id })
    |> do_query
  end

  def handle_event "select_previous_context", _, socket do

    state = IssuesMachine.select_previous_context (to_state socket)

    socket
    |> assign_state(state)
    |> push_event(:context_reprioritized, %{ id: state.selected_context.id })
  end

  def handle_event "create_new_context", %{ "view" => view }, socket do # TODO why is view passed?

    entity = case view do
      "People" -> %Person{}
      _ -> %Context{}
    end

    socket
    |> assign_state(:edit_entity, entity)
    |> assign_state(:live_action, :new_context)
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
    select_context socket, id
  end

  def handle_event "link_context", %{ "id" => id }, socket do
    
    id = to_int id
    state = IssuesMachine.select_context (to_state socket), id
    socket
    |> assign_state(state)
    |> assign_state(:live_action, :link_context)
  end

  def handle_event "reprioritize_context", %{ "id" => id }, socket do

    id = to_int id
    state =
      socket.assigns.state
      |> IssuesMachine.select_context!(id)

    socket
    |> assign_state(state)
    |> assign_state(:context_search_active, false)
    |> push_event(:context_reprioritized, %{ id: state.selected_context.id })
    |> do_query
  end

  def handle_event "toggle_context_important", %{ "target" => id }, socket do

    context = Tracker.get_context! id
    socket = socket |> assign_state(:selected_context, context)
    Tracker.update_context(context, %{ "important" => !context.important })

    socket
    |> assign_state(IssuesMachine.set_context_properties_and_keep_selected_context(to_state socket))
    |> assign_state(:context_search_active, false)
    |> push_event(:context_reprioritized, %{ id: id })
    |> do_query
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
    |> do_query
  end

  def handle_event "show_open_issues", _params, socket do
    socket
    |> assign_state(:list_issues_done_instead_open, false)
    |> do_query
  end

  def handle_event "show_closed_issues", _params, socket do
    socket
    |> assign_state(:list_issues_done_instead_open, true)
    |> do_query
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
    |> do_query
  end

  def handle_event "toggle_issue_important", %{ "target" => id }, socket do

    selected_issue = Tracker.get_issue! id
    Tracker.update_issue2(selected_issue, %{ "important" => !selected_issue.important })

    socket
    |> assign_state(IssuesMachine.set_context_properties_and_keep_selected_context(to_state socket))
    |> assign_state(:selected_issue, selected_issue)
    |> assign_state(:issue_search_active, false)
    |> push_event(:issue_reprioritized, %{ id: id })
    |> do_query
  end

  def handle_event "unarchive", %{ "target" => id }, socket do
    socket
    |> assign_state(IssuesMachine.unarchive_issue(to_state(socket), id))
    |> push_event(:issue_reprioritized, %{ id: id })
  end

  def handle_event "archive", %{ "target" => id }, socket do
    socket
    |> assign_state(IssuesMachine.archive_issue(to_state(socket), id))
  end

  defp do_query socket do
    socket
    |> assign_state(IssuesMachine.do_query(socket.assigns.state))
    |> assign_state(:live_action, :index)
  end

  defp get_selected_view params do
    if Map.has_key?(params, "view") do
      params["view"]
    end
  end

  # def should_show_issues_list_in_contexts_view nil, _ do
    # false
  # end

  # TODO only used in contexts view, so should be placed there
  # def should_show_issues_list_in_contexts_view selected_context, list_issues_done_instead_open do
    # issues = if list_issues_done_instead_open do
      # Enum.filter selected_context.issues, &(&1.issue.done)
    # else
      # Enum.filter selected_context.issues, &(!&1.issue.done)
    # end
    # length(issues) > 0
  # end

  defp apply_action(socket, :index, _params) do # ?
    socket
    |> assign_state(:issue, nil)
  end

  defp edit_issue_description socket, id do
    socket
    |> assign_state(:issue, Tracker.get_issue!(id))
    |> assign_state(:live_action, :describe)
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
    |> assign_state(:live_action, :edit_context)
  end

  defp edit_context_description socket, id do
    context = Tracker.get_context! id
    entity = case context.view do
      "People" -> People.get_person! context.person.id
      _ -> context
    end
    socket
    |> assign_state(:edit_entity, entity)
    |> assign_state(:live_action, :describe_context)
  end

  defp select_issue socket, id do
    selected_issue = Tracker.get_issue! id
    
    socket = if socket.assigns.state.issue_search_active do 
      socket
      |> push_event(:issue_reprioritized, %{ id: id })  
    else
      socket
    end
    
    socket
    |> assign_state(:selected_issue, selected_issue)
    |> assign_state(:issue_search_active, false)
  end

  defp select_context socket, id do
    state = IssuesMachine.select_context to_state(socket), id

    context_search_active = socket.assigns.state.context_search_active

    socket =
      socket
      |> assign_state(state)
      |> assign_state(:context_search_active, false)
      |> assign_state(:selected_secondary_contexts, [])

    if context_search_active do
      push_event(socket, :context_reprioritized, %{ id: state.selected_context.id })
    else
      socket
    end
  end

  defp handle_describe socket do
    if socket.assigns.state.selected_issue do
      edit_issue_description socket, socket.assigns.state.selected_issue.id
    else
      if socket.assigns.selected_context do
        edit_context_description socket, socket.assigns.state.selected_context.id
      else
        socket
      end
    end
  end

  defp handle_escape socket do
    unless socket.assigns.state.selected_secondary_contexts == [] do
      socket
      |> assign_state(:selected_secondary_contexts, [])
    else
      unless (is_nil socket.assigns.state.selected_context) do
        socket
        |> assign_state(:selected_context, nil)
        |> assign_state(:selected_contexts, [])
        |> do_query
      else
        socket
        |> assign_state(:selected_issue, nil)
      end
    end
  end

  defp assign_state socket, state do
    assign(socket, :state, state)
  end
  defp assign_state socket, key, value do
    state = socket.assigns.state
    state = put_in state[key], value
    assign(socket, :state, state)
  end

  defp reprioritize_context socket do
    unless is_nil socket.assigns.state.selected_context do
      push_event(socket, :context_reprioritized, %{ id: socket.assigns.state.selected_context.id })
    else
      socket
    end
  end

  defp to_state(socket), do: socket.assigns.state
end
