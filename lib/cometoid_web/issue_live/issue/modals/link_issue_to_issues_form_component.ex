defmodule CometoidWeb.IssueLive.Issue.Modals.LinkIssueToIssuesFormComponent do
  use CometoidWeb, :live_component

  import CometoidWeb.Helpers
  alias Cometoid.Repo.Tracker

  def update assigns, socket do

    state = assigns.state

    q = %{
      selected_context: nil, # required
      list_issues_done_instead_open: false,
      selected_view: state.selected_view,
      sort_issues_alphabetically: false
    }
    available_issues = Tracker.list_issues q

    {:ok,
      socket
      |> assign(:issues, state.selected_issue.issues)
      |> assign(:available_issues, available_issues)
      |> assign(:state, state)
    }
  end

  @impl true
  def handle_event "add", %{ "links" => %{ "issue" => issue } }, socket do

    {id, ""} = Integer.parse issue
    issue = Enum.find socket.assigns.available_issues, &(&1.id == id)

    issues = [issue|socket.assigns.issues]

    socket
    |> assign(:issues, issues)
    |> return_noreply
  end

  def handle_event "unlink_issue", %{ "target" => target }, socket do

    {id, ""} = Integer.parse target

    issues = Enum.filter socket.assigns.issues, fn issue -> issue.id != id end
    {:noreply, socket |> assign(:issues, issues)}
  end

  def handle_event "save", _, socket do

    issue_ids = Enum.map socket.assigns.issues, &(&1.id)

    {:ok, issue} = Tracker.link_issues socket.assigns.state.selected_issue, issue_ids

    send self(), {:after_edit_form_save, issue}
    socket
    |> return_noreply
  end

  def convert_for_select available_issues, issues do
    issue_ids = Enum.map issues, &(&1.id)

    available_issues
    |> Enum.filter(&(&1.id not in issue_ids))
    |> Enum.map(&({&1.title, &1.id}))
  end
end
