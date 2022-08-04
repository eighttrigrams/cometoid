defmodule CometoidWeb.IssueLive.Issue.Modals.FormComponent do
  use CometoidWeb, :live_component

  alias Cometoid.Repo.Tracker
  import CometoidWeb.LiveHelpers
  import CometoidWeb.DateHelpers
  import CometoidWeb.DateFormHelpers

  @impl true
  def update(%{issue: issue} = assigns, socket) do

    state = assigns.state

    q = %{
      search: %{ 
        q: "", 
        show_all_issues: true 
      },
      selected_context: nil,
      selected_issue: nil,
      list_issues_done_instead_open: false,
      selected_view: state.selected_view,
      sort_issues_alphabetically: false
    }

    available_issues = 
      q
      |> Tracker.list_issues
      |> Enum.filter(fn issue -> issue.id != state.selected_issue.id end)

    {issue_params, day_options} = init_params issue.event

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:year_options, 1900..2050)
      |> assign(:day_options, day_options)
      |> assign(:issue_params, issue_params)
      |> assign(:changeset, Tracker.change_issue(issue))
      |> assign(:issues, state.selected_issue.issues)
      |> assign(:available_issues, available_issues)
      |> assign(:issues_to_display, available_issues)
      |> assign(:state, state)
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
        issue_ids = Enum.map socket.assigns.issues, &(&1.id)
        {:ok, issue} = Tracker.link_issues socket.assigns.state.selected_issue, issue_ids
        send self(), {:after_edit_form_save, issue}
      _ -> IO.puts "error"
    end
    
    socket
    |> return_noreply
  end

  @impl true
  def handle_event "add", %{ "links" => %{ "issue" => issue } }, socket do

    id = to_int issue
    issue = Enum.find socket.assigns.available_issues, &(&1.id == id)

    issues = [issue|socket.assigns.issues]

    socket
    |> assign(:issues, issues)
    |> return_noreply
  end

  def handle_event "change", %{ "links" => %{ "filter" => filter }}, 
      %{ assigns: %{ available_issues: available_issues } } = socket do

    filter = String.downcase filter

    issues_to_display = Enum.filter available_issues, fn i ->
      elements = String.split(i.title, " ")
      a = Enum.reduce elements, 0, fn v, a -> 
        a + if (String.starts_with? (String.downcase v), filter) do 1 else 0 end
      end
      a > 0
    end

    socket
    |> assign(:issues_to_display, issues_to_display)
    |> return_noreply
  end

  def handle_event "unlink_issue", %{ "target" => target }, socket do

    id = to_int target

    issues = Enum.filter socket.assigns.issues, fn issue -> issue.id != id end
    socket
    |> assign(:issues, issues)
    |> return_noreply
  end

  def convert_for_select available_issues, issues do
    issue_ids = Enum.map issues, &(&1.id)

    available_issues
    |> Enum.filter(&(&1.id not in issue_ids))
    |> Enum.map(&({&1.title, &1.id}))
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
