defmodule CometoidWeb.IssueLive.Issue.Modals.FormComponent do
  use CometoidWeb, :live_component

  alias Cometoid.Repo.Tracker

  @impl true
  def update(%{issue: issue} = assigns, socket) do
    {
      :ok,
      socket
        |> assign(assigns)
        |> assign(:issue_params, %{})
        |> assign(:changeset, Tracker.change_issue(issue))
    }
  end

  def handle_event("changes", %{ "issue" => issue_params }, socket) do

    issue_params = if issue_params["has_event"] == "true" do
      issue_params
    else
      Map.delete issue_params, "event"
    end

    socket = socket
      |> assign(:issue_params, issue_params)
      |> assign(:has_event,
        (if issue_params["has_event"] == "true", do: true, else: false))
    {:noreply, socket}
  end

  def handle_event("save",_, socket) do
    save_issue(socket, socket.assigns.action, socket.assigns.issue_params)
  end

  defp save_issue(socket, :edit, issue_params) do

    case Tracker.update_issue(socket.assigns.issue, issue_params, []) do
      {:ok, issue} ->
        send self(), {:after_edit_form_save, issue}
        {:noreply, socket |> put_flash(:info, "Issue updated successfully")
        }
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
