defmodule CometoidWeb.IssueLive.NewComponent do
  use CometoidWeb, :live_component

  alias Cometoid.Repo.Tracker

  @impl true
  def update(%{issue: issue} = assigns, socket) do
    changeset = Tracker.change_issue(issue)
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  def handle_event("save", %{"issue" => issue_params}, socket) do
    save_issue(socket, socket.assigns.action, issue_params)
  end

  defp save_issue(socket, :new, %{ "title" => title }) do
    case create_new_issue(socket, title) do
      {:ok, issue} ->
        send self(), {:after_edit_form_save, issue}
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp create_new_issue(socket, title) do
    Tracker.create_issue(
        title,
        socket.assigns.selected_context)
  end
end
