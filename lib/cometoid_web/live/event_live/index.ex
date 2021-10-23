defmodule CometoidWeb.EventLive.Index do
  use CometoidWeb, :live_view

  alias CometoidWeb.IssueLive
  alias CometoidWeb.EventLive
  alias CometoidWeb.PersonLive
  alias CometoidWeb.Theme

  alias Cometoid.Repo.Tracker
  alias Cometoid.Repo.People
  alias Cometoid.Repo.Calendar
  alias Cometoid.Model.Calendar.Event
  alias Cometoid.Editor

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(Theme.get)
    |> assign(:show_archived, false)
    |> assign(:view, "Events")
    |> do_query
    |> return_ok
  end

  def handle_event "mouse_leave", _, socket do
    socket
    |> return_noreply
  end

  def handle_event "switch-theme", %{ "name" => name }, socket do
    Theme.toggle
    socket
    |> assign(Theme.get)
    |> return_noreply
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def handle_event("edit_event", %{ "target" => id }, socket) do
    socket
    |> assign(:edit_event, Calendar.get_event!(id))
    |> assign(:live_action, :edit)
    |> return_noreply
  end

  def handle_info({:modal_closed}, socket) do
    socket
    |> assign(:live_action, nil)
    |> return_noreply
  end

  def handle_info({:after_edit_form_save, %{ event: event }}, socket) do
    selected_event = Calendar.get_event! event.id
    socket
    |> assign(:live_action, nil)
    |> do_query
    |> assign(:selected_event, selected_event)
    |> return_noreply
  end

  def handle_info({:after_edit_form_save, issue}, socket) do
    selected_event = Calendar.get_event!(issue.event.id)
    socket
    |> assign(:live_action, nil)
    |> do_query
    |> assign(:selected_event, selected_event)
    |> return_noreply
  end

  def handle_event "unarchive", %{ "target" => id }, socket do
    event = Calendar.get_event! id
    Calendar.update_event(event, %{ "archived" => false })
    socket
    |> do_query
    |> return_noreply
  end

  def handle_event "archive", %{ "target" => id }, socket do
    event = Calendar.get_event! id
    Calendar.update_event(event, %{ "archived" => true })
    socket
    |> do_query
    |> return_noreply
  end

  def handle_event("create_new_event", params, socket) do
    socket
    |> assign(:edit_event, %Event{})
    |> assign(:live_action, :new)
    |> return_noreply
  end

  def handle_event("toggle_show_archived", params, socket) do
    socket
    |> assign(:show_archived, !socket.assigns.show_archived)
    |> do_query
    |> return_noreply
  end

  defp apply_action(socket, :index, _params) do # ?
    socket
    |> assign(:edit_event, nil)
  end

  def handle_event("select_event", %{ "target" => id }, socket) do
    selected_event = Calendar.get_event!(id)
    socket =
      socket
      |> assign(:selected_event, selected_event)
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    event = Calendar.get_event!(id)
    {:ok, _} = Calendar.delete_event(event)
    Editor.delete_event event
    socket
    |> do_query
    |> return_noreply
  end

  def handle_event("open_event_in_editor", %{ "target" => id }, socket) do
    selected_event = Calendar.get_event!(id)
    Editor.open_event selected_event
    socket
    |> assign(:selected_event, selected_event)
    |> return_noreply
  end

  defp do_query(socket) do
    socket
    |> assign(:events, Calendar.list_events(socket.assigns.show_archived))
  end

  defp return_noreply(socket), do: {:noreply, socket}

  defp return_ok(socket), do: {:ok, socket}
end
