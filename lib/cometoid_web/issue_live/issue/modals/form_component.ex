defmodule CometoidWeb.IssueLive.Issue.Modals.FormComponent do
  use CometoidWeb, :live_component

  alias Cometoid.Repo.Tracker
  import CometoidWeb.LiveHelpers
  import CometoidWeb.DateFormHelpers

  @impl true
  def update(%{issue: issue} = assigns, socket) do

    issue_params = init_params(if issue.event do issue.event.date end)
    day_options = get_day_options issue_params["event"]["date"] # TODO add version which takes params

    {
      :ok,
      socket
        |> assign(assigns)
        |> assign(:year_options, 1900..2050)
        |> assign(:day_options, day_options)
        |> assign(:issue_params, issue_params)
        |> assign(:changeset, Tracker.change_issue(issue))
    }
  end

  @impl true
  def handle_event "changes", %{
      "_target" => ["issue", "event", "date", field],
      "issue" => issue_params }, socket do

    {issue_params, day_options} = adjust_date issue_params

    socket
    |> assign(:day_options, day_options)
    |> assign(:issue_params, issue_params)
    |> return_noreply
  end

  def handle_event "changes", %{ "issue" => issue_params }, socket do

    issue_params = update_params issue_params, socket.assigns.issue_params

    socket
    |> assign(:issue_params, issue_params)
    |> return_noreply
  end

  @doc """
  called from SaveHook via pushEventTo()
  """
  def handle_event "save", title, socket do

    issue_params = socket.assigns.issue_params
      |> clean_event
      |> Map.put("title", String.trim(title))

    # if socket.assigns.changed? or socket.assigns.issue.title != title do
    save_issue socket, socket.assigns.action, issue_params
    # else
      # send self(), {:modal_closed}
      # {:noreply, socket}
    # end
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
