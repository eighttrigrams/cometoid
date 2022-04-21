defmodule CometoidWeb.IssueLive.Issue.Modals.FormComponent do
  use CometoidWeb, :live_component

  alias Cometoid.Repo.Tracker
  import CometoidWeb.LiveHelpers

  @impl true
  def update(%{issue: issue} = assigns, socket) do

    {%{"year" => year, "month" => month, "day" => day}, day_options} = if not is_nil(issue.event) do
      {(to_date_map issue.event.date), Date.days_in_month(issue.event.date)}
    else
      {(to_date_map local_time()), 31} # will then be reset in "changes" event
    end

    {
      :ok,
      socket
        |> assign(assigns)
        |> assign(:year_options, 1900..2050)
        |> assign(:month_options, 1..12)
        |> assign(:year, year)
        |> assign(:month, month)
        |> assign(:day, day)
        |> assign(:day_options, 1..day_options)
        |> assign(:issue_params, %{})
        |> assign(:changed?, false)
        |> assign(:changeset, Tracker.change_issue(issue))
    }
  end

  @impl true
  def handle_event "changes", %{
      "_target" => ["issue", "event", "date", field],
      "issue" => %{ "event" => %{ "date" => date = %{ "day" => day, "month" => month, "year" => year }}} = issue_params }, socket do

    day_options = get_day_options(issue_params)
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
    |> assign(:day, day)
    |> assign(:month, month)
    |> assign(:year, year)
    |> assign(:changed?, true) # TODO review, do we need this? if yes, can we make it that it is only assigned if something has actually changed?
    |> return_noreply
  end

  def handle_event "changes", %{
      "issue" => %{ "has_event" => has_event } = issue_params } = change, socket do

    issue_params = if Map.has_key? issue_params, "event" do
        issue_params
      else
        set_new_event_in issue_params
      end

    if has_event == "true" do
      socket
      |> assign(:issue_params, issue_params)
      |> assign(:has_event, true)
      |> assign(:year, issue_params["event"]["date"]["year"])
      |> assign(:month, issue_params["event"]["date"]["month"])
      |> assign(:day, issue_params["event"]["date"]["day"])
      |> assign(:day_options, get_day_options issue_params)
    else
      socket
      |> assign(:issue_params, (Map.delete issue_params, "event"))
      |> assign(:has_event, false)
    end
    |> assign(:changed?, true)
    |> return_noreply
  end

  @doc """
  called from SaveHook via pushEventTo()
  """
  def handle_event "save", title, socket do
    issue_params = Map.put socket.assigns.issue_params, "title", title
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

  defp set_new_event_in issue_params do
    Map.merge issue_params, %{
      "event" => %{
        "archived" => "false",
        "date" => to_date_map(local_time())
      }
    }
  end

  defp to_date_map {{year, month, day}, _} do
    day = Integer.to_string(day)
    month = Integer.to_string(month)
    year = Integer.to_string(year)
    %{"day" => day, "month" => month, "year" => year }
  end

  defp to_date_map date_sigil do
    %{ "year" => date_sigil.year, "month" => date_sigil.month, "day" => date_sigil.day }
  end

  defp local_time do
    :calendar.local_time()
  end

  defp get_day_options %{ "event" => %{ "date" => %{ "year" => year, "month" => month}}} do
    month = if String.length(month) == 1 do "0" <> month else month end
    date = Date.from_iso8601! year <> "-" <> month <> "-" <> "01"
    1..Date.days_in_month date
  end
end
