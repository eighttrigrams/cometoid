defmodule CometoidWeb.IssueLive.Issue.Modals.FormComponent do
  use CometoidWeb, :live_component

  alias Cometoid.Repo.Tracker
  import CometoidWeb.LiveHelpers
  import CometoidWeb.DateFormHelpers

  @impl true
  def update(%{issue: issue} = assigns, socket) do

    issue_params = init_params(if issue.event do issue.event.date end)
    day_options = get_day_options issue_params["event"]["date"]

    {
      :ok,
      socket
        |> assign(assigns)
        |> assign(:year_options, 1900..2050)
        |> assign(:month_options, 1..12)
        |> assign(:day_options, day_options)
        |> assign(:issue_params, issue_params)
        |> assign(:changed?, false)
        |> assign(:changeset, Tracker.change_issue(issue))
    }
  end

  @impl true
  def handle_event "changes", %{
      "_target" => ["issue", "event", "date", field],
      "issue" => %{ "event" => %{ "date" => date = %{ "day" => day, "month" => month, "year" => year }}} = issue_params }, socket do

    day_options = get_day_options(date)
    {day_i, ""} = Integer.parse day
    day = unless day_i in day_options do
        Integer.to_string List.last Enum.to_list day_options
      else
        day
      end

    issue_params = put_in issue_params["event"]["date"]["day"], day

    socket
    |> assign(:day_options, day_options)
    |> assign(:issue_params, issue_params)
    |> assign(:changed?, true) # TODO review, do we need this? if yes, can we make it that it is only assigned if something has actually changed?
    |> return_noreply
  end

  def handle_event "changes", %{
      "issue" => %{ "has_event?" => has_event? }}, socket do

    issue_params = Map.put socket.assigns.issue_params, "has_event?", has_event?
    socket
    |> assign(:issue_params, issue_params)
    |> assign(:changed?, true)
    |> return_noreply
  end

  @doc """
  called from SaveHook via pushEventTo()
  """
  def handle_event "save", title, socket do

    issue_params = socket.assigns.issue_params
      |> clean_event
      |> Map.put("title", title)

    if socket.assigns.changed? or socket.assigns.issue.title != title do
      save_issue socket, socket.assigns.action, issue_params
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
