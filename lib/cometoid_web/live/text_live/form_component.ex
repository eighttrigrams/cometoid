defmodule CometoidWeb.TextLive.FormComponent do
  use CometoidWeb, :live_component

  alias Cometoid.Repo.Writing

  @impl true
  def update(%{text: text} = assigns, socket) do
    changeset = Writing.change_text(text)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"text" => text_params}, socket) do
    changeset =
      socket.assigns.text
      |> Writing.change_text(text_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"text" => text_params}, socket) do
    save_text(socket, socket.assigns.action, text_params)
  end

  defp save_text(socket, :edit_context, text_params) do
    case Writing.update_text(socket.assigns.text, text_params) do
      {:ok, text} ->
        send self(), {:after_edit_form_save, %{ context_id: text.context.id }}
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_text(socket, :new_context, text_params) do
    case Writing.create_text(text_params) do
      {:ok, text} ->
        send self(), {:after_edit_form_save, %{ context_id: text.context.id }}
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
