defmodule CometoidWeb.IssueLive.Issue.Modals.FormComponent do
  use CometoidWeb, :live_component

  alias Cometoid.Repo.Tracker
  import CometoidWeb.LiveHelpers

  @impl true
  def update(%{issue: issue} = assigns, socket) do
    {
      :ok,
      socket
        |> assign(assigns)
        |> assign(:year_options, 1900..2050)
        |> assign(:month_options, 1..12)
        |> assign(:day_options, 1..31)
        |> assign(:issue_params, %{})
        |> assign(:changed?, false)
        |> assign(:changeset, Tracker.change_issue(issue))
    }
  end

  # TODO if changing month or year, it should not adjust the date, unless it is not in the month
  @impl true
  def handle_event "changes", %{
    "issue" => %{ "has_event" => has_event } = issue_params }, socket do

    issue_params = if Map.has_key? issue_params, "event" do
        issue_params
      else
        set_new_event_in issue_params
      end

    if has_event == "true" do
      socket
      |> assign(:issue_params, issue_params)
      |> assign(:has_event, true)
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

  defp get_day_options %{ "event" => %{ "date" => %{ "year" => year, "month" => month}}} do
    month = if String.length(month) == 1 do "0" <> month else month end
    date = Date.from_iso8601! year <> "-" <> month <> "-" <> "01"
    1..Date.days_in_month date
  end
end
