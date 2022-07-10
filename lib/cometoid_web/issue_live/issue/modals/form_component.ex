defmodule CometoidWeb.IssueLive.Issue.Modals.FormComponent do
  use CometoidWeb, :live_component

  alias Cometoid.Repo.Tracker
  import CometoidWeb.LiveHelpers
  import CometoidWeb.DateHelpers
  import CometoidWeb.DateFormHelpers

  @impl true
  def update(%{issue: issue} = assigns, socket) do

    {issue_params, day_options} = init_params issue.event

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
      "_target" => ["issue", "event", "date", _field],
      "issue" => issue_params }, socket do

    {day, day_options} = adjust_date issue_params["event"]["date"]
    issue_params = put_in issue_params["event"]["date"]["day"], day

    socket
    |> assign(:day_options, day_options)
    |> assign(:issue_params, issue_params)
    |> return_noreply
  end

  def handle_event "changes", %{ "issue" => issue_params }, socket do

    issue_params = put_back_event issue_params, socket.assigns.issue_params, "event"

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

    case Tracker.update_issue(socket.assigns.issue, issue_params, []) do
      {:ok, issue} ->
        send self(), {:after_edit_form_save, issue}
        {:noreply, socket |> put_flash(:info, "Issue updated successfully")
        }
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def init_params _event = nil do
    params = %{
      "has_event?" => "false",
      "event" => %{
        "archived" => "false",
        "date" => local_time()
      }
    }
    day_options = get_day_options params["event"]["date"]
    {params, day_options}
  end

  def init_params event do
    params = %{
      "has_event?" => "true",
      "event" => %{
        "archived" => to_string(event.archived),
        "date" => to_date_map(event.date)
      }
    }
    day_options = get_day_options params["event"]["date"]
    {params, day_options}
  end

  def clean_event params do
    if has_event? params do
      params
    else
      Map.delete params, "event"
    end
  end

  defp has_event? %{ "has_event?" => has_event? } do
    has_event? == "true"
  end
end
