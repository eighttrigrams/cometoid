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
    |> assign_state(:selected_view, "Events")
    |> refresh_issues
    |> return_ok
  end

  @impl true
  def handle_params(_params, _url, socket) do
    socket
  end

  @impl true
  def handle_info {:modal_closed}, socket do
    socket
  end

  def handle_info {:after_edit_form_save, %{ event: event }} = _issue, socket do

    selected_event = if event do Calendar.get_event! event.id else nil end
    socket
    |> assign_state(:selected_event, selected_event)
    |> refresh_issues
    |> assign_state(:edit_context, nil)
    |> assign_state(:edit_issue, nil)
  end

  def handle_info {:after_edit_form_save, %{ context_id: id }}, socket do

    context = Tracker.get_context! id
    person = People.get_person! context.person.id
    selected_event = Calendar.get_event! person.birthday.id
    socket
    |> assign_state(:selected_event, selected_event)
    |> refresh_issues
    |> assign_state(:edit_context, nil)
    |> assign_state(:edit_issue, nil)
  end

  @impl true
  def handle_event "keydown", %{ "key" => key }, %{ assigns: %{ modal: nil, state: state } } = socket do
    case key do
      "e" ->
        if state.selected_event do
          if state.selected_event.issue do
            edit_issue socket, state.selected_event.issue.id
          else # Person
            edit_person socket, state.selected_event.person.id
          end
        else
          socket
        end
      "d" ->
        if state.selected_event do
          if state.selected_event.issue do
            issue = Tracker.get_issue! state.selected_event.issue.id
            socket
            |> assign_state(:issue, issue)
            |> assign(:modal, :describe)
          else # Person
            person = People.get_person! state.selected_event.person.id
            socket
            |> assign_state(:edit_entity, person)
            |> assign(:modal, :describe_context)
          end
        else
          socket
        end
      _ ->
        socket
    end
  end

  def handle_event("keydown", _params, socket), do: socket

  def handle_event "switch-theme", %{ "name" => _name }, socket do
    Theme.toggle!
    socket
    |> assign(Theme.get)
  end

  def handle_event "edit_event", id, socket do

    event = Calendar.get_event!(id)
    if event.issue do 
      edit_issue socket, event.issue.id
    else # Person
      edit_person socket, event.person.id
    end
  end

  def handle_event "delete_issue", %{ "id" => id }, socket do

    id = to_int id
    issue = Tracker.get_issue! id
    {:ok, _} = Tracker.delete_issue issue

    socket
    |> refresh_issues
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

  def handle_event("select_event", %{ "target" => id }, socket) do
    selected_event = Calendar.get_event!(id)
    socket
    |> assign_state(:selected_event, selected_event)
  end

  def handle_event "mouse_leave", _, socket do
    socket
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

  defp edit_person socket, id do
    person = People.get_person! id
    socket
    |> assign_state(:edit_entity, person)
    |> assign_state(:edit_selected_view, person.context.view)
    |> assign(:modal, :edit_context)
  end

  defp edit_issue socket, id do
    issue = Tracker.get_issue! id
    socket
    |> assign_state(:issue, issue)
    |> assign(:modal, :edit_issue)
  end

  defp refresh_issues socket do
    socket
    |> assign_state(:events, Calendar.list_events(socket.assigns.state.show_archived))
    |> assign(:modal, nil)
  end
end
