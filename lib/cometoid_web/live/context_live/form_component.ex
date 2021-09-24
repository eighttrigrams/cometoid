defmodule CometoidWeb.ContextLive.FormComponent do
  use CometoidWeb, :live_component

  alias Cometoid.Repo.Tracker

  @impl true
  def update(%{context: context} = assigns, socket) do

    changeset = Tracker.change_context(context)
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"context" => context_params}, socket) do
    changeset =
      socket.assigns.context
      |> Tracker.change_context(context_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"context" => context_params}, socket) do
    save_context(socket, socket.assigns.action, context_params)
  end

  defp save_context(socket, :edit_context, context_params) do
    case Tracker.update_context(socket.assigns.context, context_params) do
      {:ok, context} ->
        send self(), {:after_edit_form_save, %{ context_id: context.id }}
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_context(socket, :new_context, context_params) do
    case Tracker.create_context(context_params, socket.assigns.selected_context_type) do
      {:ok, context} ->
        send self(), {:after_edit_form_save, %{ context_id: context.id }}
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
