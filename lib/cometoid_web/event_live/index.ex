defmodule CometoidWeb.EventLive.Index do
  use CometoidWeb, :live_view
  use CometoidWeb.IssueLive.WrapHandle

  alias CometoidWeb.IssueLive.Person
  alias CometoidWeb.Theme

  alias Cometoid.Repo.Tracker
  alias Cometoid.Repo.People
  alias Cometoid.Repo.Calendar

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:state, %{})
    |> assign(Theme.get)
    |> assign_state(:show_archived, false)
    |> assign(:view, "Events")
    |> assign_state(:control_pressed, false)
    |> do_query
    |> return_ok
  end

  @impl true
  def handle_params(params, _url, socket) do
    apply_action(socket, socket.assigns.live_action, params)
  end

  @impl true
  def handle_info {:modal_closed}, socket do
    socket
    |> assign(:live_action, nil)
  end

  def handle_info {:after_edit_form_save, %{ event: event }} = _issue, socket do

    selected_event = if event do Calendar.get_event! event.id else nil end
    socket
    |> assign_state(:selected_event, selected_event)
    |> do_query
    |> assign(:live_action, nil)
    |> assign_state(:edit_event, nil)
  end

  def handle_info {:after_edit_form_save, %{ context_id: id }}, socket do

    context = Tracker.get_context! id
    person = People.get_person! context.id
    selected_event = Calendar.get_event! person.birthday.id
    socket
    |> assign_state(:selected_event, selected_event)
    |> do_query
    |> assign(:live_action, nil)
    |> assign_state(:edit_event, nil)
  end

  @impl true
  def handle_event "right_click", _, socket do
    socket
    |> assign_state(:control_pressed, true)
  end

  def handle_event "mouse_leave", _, socket do
    socket
    |> assign_state(:control_pressed, false)
  end

  def handle_event "switch-theme", %{ "name" => _name }, socket do
    Theme.toggle!
    socket
    |> assign(Theme.get)
  end

  def handle_event("edit_event", id, socket) do
    socket
    |> assign_state(:edit_event, Calendar.get_event!(id))
    |> assign(:live_action, :edit_event)
  end

  def handle_event "edit_issue_description", _, socket do
    socket
    |> assign_state(:issue, Tracker.get_issue!(socket.assigns.state.selected_event.issue.id))
    |> assign(:live_action, :describe)
  end

  def handle_event "edit_context_description", _, socket do
    socket
    |> assign_state(:edit_entity, socket.assigns.state.selected_event.person)
    |> assign(:live_action, :describe_context)
  end

  def handle_event "unarchive", %{ "target" => id }, socket do
    event = Calendar.get_event! id
    Calendar.update_event(event, %{ "archived" => false })
    socket
    |> do_query
  end

  def handle_event "archive", %{ "target" => id }, socket do
    event = Calendar.get_event! id
    Calendar.update_event(event, %{ "archived" => true })
    socket
    |> do_query
  end

  def handle_event "toggle_show_archived", _params, socket do
    socket
    |> assign_state(:show_archived, !socket.assigns.state.show_archived)
    |> do_query
  end

  def handle_event("select_event", %{ "target" => id }, socket) do
    selected_event = Calendar.get_event!(id)
    socket
    |> assign_state(:selected_event, selected_event)
  end

  defp apply_action(socket, :index, _params) do # ?
    socket
    |> assign_state(:edit_event, nil)
  end

  def get_events_to_display events do
    Enum.filter events, fn event ->
      if is_nil(event.person) do
        true
      else
        event.person.use_birthday
      end
    end
  end

  defp do_query(socket) do
    socket
    |> assign_state(:events, Calendar.list_events(socket.assigns.state.show_archived))
  end

  # TODO remove duplication with issue.ex
  defp assign_state socket, state do
    assign(socket, :state, state)
  end
  defp assign_state socket, key, value do
    state = socket.assigns.state
    state = put_in state[key], value
    assign(socket, :state, state)
  end
end
