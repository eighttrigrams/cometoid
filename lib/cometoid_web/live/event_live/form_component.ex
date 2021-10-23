defmodule CometoidWeb.EventLive.FormComponent do
  use CometoidWeb, :live_component

  alias Cometoid.Repo.Calendar

  @impl true
  def update(%{event: event} = assigns, socket) do
    changeset = Calendar.change_event(event)
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"event" => event_params}, socket) do
    changeset =
      socket.assigns.event
      |> Calendar.change_event(event_params)
      |> Map.put(:action, :validate)
    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"event" => event_params}, socket) do
    save_event(socket, socket.assigns.action, event_params)
  end

  defp save_event(socket, :edit_event, event_params) do
    case Calendar.update_event(socket.assigns.event, event_params) do
      {:ok, event} ->
        send self(), {:after_edit_form_save, %{ event: event }}
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_event(socket, :new_event, event_params) do
    case Calendar.create_event(event_params) do
      {:ok, event} ->
        send self(), {:after_edit_form_save, %{ event: event }}
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
