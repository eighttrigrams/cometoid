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

  @impl true
  def handle_event "changes", %{ "issue" => issue_params }, socket do
    socket =
      socket
      |> assign(:issue_params, issue_params)
    {:noreply, socket}
  end

  def handle_event("save", title, socket) do

    [short_title, title] = case String.split(title, "|") do
      [title] -> [nil, title]
      [short_title | title] -> [short_title, Enum.join(title, "|")]
    end
    short_title = if short_title do String.trim(short_title) end
    title = String.trim(title)

    save_issue(socket, socket.assigns.action, %{
      "title" => title, "short_title" => short_title })
  end

  defp save_issue(socket, :new, %{ "title" => title, "short_title" => short_title }) do
    case create_new_issue(socket, title, short_title) do
      {:ok, issue} ->
        send self(), {:after_edit_form_save, issue}
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp create_new_issue(socket, title, short_title) do
    secondary_contexts =
      Enum.map socket.assigns.state.selected_secondary_contexts,
      &(Tracker.get_context!(&1))
    contexts = [socket.assigns.state.selected_context|secondary_contexts]
    Tracker.create_issue title, short_title, contexts
  end
end
