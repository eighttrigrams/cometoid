defmodule CometoidWeb.IssueLive.Issue.Modals.LinkIssueToIssuesFormComponent do
  use CometoidWeb, :live_component
  alias Cometoid.Repo.Tracker

  def update assigns, socket do
    state = assigns.state
    {:ok,
      socket
      |> assign(:issues, state.selected_issue.issues)
      |> assign(:state, state)
    }
  end

  @impl true
  def handle_event "unlink_issue", %{ "target" => target }, socket do

    {id, ""} = Integer.parse target

    issues = Enum.filter socket.assigns.issues, fn issue -> issue.id != id end
    {:noreply, socket |> assign(:issues, issues)}
  end
end
