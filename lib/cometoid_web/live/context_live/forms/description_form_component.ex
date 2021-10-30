defmodule CometoidWeb.ContextLive.Forms.DescriptionFormComponent do
  use CometoidWeb, :live_component

  alias Cometoid.Repo.Tracker
  alias Cometoid.Repo.People

  @impl true
  def update(%{context: context} = assigns, socket) do

    changeset = unless Map.has_key?(context, :context_type) do
      People.change_person_description(context)
    else
      Tracker.change_context(context)
    end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  def handle_event("save", %{"context" => context_params }, socket) do
    save_context(socket, socket.assigns.action, context_params)
  end

  def handle_event("save", %{"person" => context_params }, socket) do
    save_context(socket, socket.assigns.action, context_params)
  end

  defp save_context(socket, :describe_context, context_params) do

    unless Map.has_key?(socket.assigns.context, :context_type) do
      case People.update_person_description(socket.assigns.context, context_params) do
        {:ok, context} ->
          send self(), {:after_edit_form_save, %{ context_id: context.id }}
          {:noreply, socket}
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, :changeset, changeset)}
      end
    else
      case Tracker.update_context(socket.assigns.context, context_params) do
        {:ok, context} ->
          send self(), {:after_edit_form_save, %{ context_id: context.id }}
          {:noreply, socket}
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, :changeset, changeset)}
      end
    end
  end
end
