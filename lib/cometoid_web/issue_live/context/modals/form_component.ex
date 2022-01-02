defmodule CometoidWeb.IssueLive.Context.Modals.FormComponent do
  use CometoidWeb, :live_component

  alias Cometoid.Repo.Tracker

  @impl true
  def update(%{context: context} = assigns, socket) do

    changeset = Tracker.change_context(context)
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:context_params, %{})
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("changes", %{"context" => context_params}, socket) do
    socket =
      socket
      |> assign(:context_params, context_params)
    {:noreply, socket}
  end

  def handle_event("save", _, socket) do
    save_context(socket, socket.assigns.action, socket.assigns.context_params)
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
    case Tracker.create_context(context_params) do
      {:ok, context} ->
        send self(), {:after_edit_form_save, %{ context_id: context.id }}
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
