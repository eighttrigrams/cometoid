defmodule CometoidWeb.IssueLive.Issue.Modals.FormComponent do
  use CometoidWeb, :live_component

  alias Cometoid.Repo.Tracker

  @impl true
  def update(%{issue: issue} = assigns, socket) do
    {
      :ok,
      socket
        |> assign(assigns)
        |> assign(:title, nil)
        |> assign(:issue_params, %{})
        |> assign(:changed?, false)
        |> assign(:changeset, Tracker.change_issue(issue))
    }
  end

  @impl true
  def handle_event "changes", %{ "issue" => issue_params }, socket do

    issue_params = if issue_params["has_event"] == "true" do

      if Map.has_key? issue_params, "event" do
        issue_params
      else
        {{year, month, day}, _} = :calendar.local_time()
        day = Integer.to_string(day)
        month = Integer.to_string(month)
        year = Integer.to_string(year)
        Map.merge issue_params, %{
          "event" => %{
            "archived" => "false",
            "date" => %{"day" => day, "month" => month, "year" => year }
          }
        }
      end
    else
      Map.delete issue_params, "event"
    end

    socket = socket
      |> assign(:issue_params, issue_params)
      |> assign(:has_event,
        (if issue_params["has_event"] == "true", do: true, else: false))
      |> assign(:changed?, true)
    {:noreply, socket}
  end

  def handle_event "change_title", %{ "value" => title }, socket do
    if title == socket.assigns.title do
      {:noreply, socket}
    else
      socket =
        socket
        |> assign(:title, title)
        |> assign(:changed?, true)
      {:noreply, socket}
    end
  end

  def handle_event "save", _, socket do
    if socket.assigns.changed? do
      save_issue(socket, socket.assigns.action, Map.put(
        socket.assigns.issue_params, "title", socket.assigns.title))
    else
      send self(), {:modal_closed}
      {:noreply, socket}
    end
  end

  defp save_issue socket, :edit, issue_params do

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
