defmodule CometoidWeb.IssueLive.Issue.Modals.NewComponent do
  use CometoidWeb, :live_component

  alias Cometoid.Repo.Tracker

  @impl true
  def update(%{state: state} = assigns, socket) do
    changeset = Tracker.change_issue(state.issue)
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  def handle_event "changes", %{ "issue" => issue_params }, socket do
    socket =
      socket
      |> assign(:issue_params, issue_params)
    {:noreply, socket}
  end

  def handle_event("save", _, socket) do
    save_issue(socket, socket.assigns.action, socket.assigns.issue_params)
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
    secondary_contexts =
      Enum.map socket.assigns.state.selected_secondary_contexts,
      &(Tracker.get_context!(&1))
    contexts = [socket.assigns.state.selected_context|secondary_contexts]
    Tracker.create_issue title, contexts
  end
end
