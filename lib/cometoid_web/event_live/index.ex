defmodule CometoidWeb.EventLive.Index do
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
    |> assign(:modal, nil)
    |> assign(Theme.get)
    |> assign_state(:show_archived, false)
    |> assign(:view, "Events")
    |> assign_state(:control_pressed, false)
    |> refresh_issues
    |> return_ok
  end

  @impl true
  def handle_params(params, _url, socket) do
    # apply_action(socket, socket.assigns.modal, params) TODO review
    socket
  end

  @impl true
  def handle_info {:modal_closed}, socket do
    socket
    |> assign(:modal, nil)
  end

  def handle_info {:after_edit_form_save, %{ event: event }} = _issue, socket do

    selected_event = if event do Calendar.get_event! event.id else nil end
    socket
    |> assign_state(:selected_event, selected_event)
    |> refresh_issues
    |> assign(:modal, nil)
    |> assign_state(:edit_event, nil)
  end

  def handle_info {:after_edit_form_save, %{ context_id: id }}, socket do

    context = Tracker.get_context! id
    person = People.get_person! context.id
    selected_event = Calendar.get_event! person.birthday.id
    socket
    |> assign_state(:selected_event, selected_event)
    |> refresh_issues
    |> assign(:modal, nil)
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
    |> assign(:modal, :edit_event)
  end

  def handle_event "edit_issue_description", _, socket do
    socket
    |> assign_state(:issue, Tracker.get_issue!(socket.assigns.state.selected_event.issue.id))
    |> assign(:modal, :describe)
  end

  def handle_event "edit_context_description", _, socket do
    socket
    |> assign_state(:edit_entity, socket.assigns.state.selected_event.person)
    |> assign(:modal, :describe_context)
  end

  def handle_event "unarchive", %{ "target" => id }, socket do
    event = Calendar.get_event! id
    Calendar.update_event(event, %{ "archived" => false })
    socket
    |> refresh_issues
  end

  def handle_event "archive", %{ "target" => id }, socket do
    event = Calendar.get_event! id
    Calendar.update_event(event, %{ "archived" => true })
    socket
    |> refresh_issues
  end

  def handle_event "toggle_show_archived", _params, socket do
    socket
    |> assign_state(:show_archived, !socket.assigns.state.show_archived)
    |> refresh_issues
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

  defp refresh_issues(socket) do
    socket
    |> assign_state(:events, Calendar.list_events(socket.assigns.state.show_archived))
  end
end
