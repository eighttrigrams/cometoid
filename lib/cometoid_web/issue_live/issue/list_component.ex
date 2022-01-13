defmodule CometoidWeb.IssueLive.Issue.ListComponent do
  use CometoidWeb, :live_component

  alias CometoidWeb.IssueLive.Issue.ListComponent
  alias CometoidWeb.IssueLive.Issue.ListItemComponent

  @impl true
  def mount socket do
    socket
    |> assign(:q, "")
    |> assign(:filtered_issues, [])
    |> return_ok
  end

  @impl true
  def update assigns, socket do
    socket
    |> assign(assigns)
    |> assign(:q, "")
    |> filter_issues
    |> return_ok
  end

  @impl true
  def handle_event "changes", %{ "issue_search" => %{ "q" => q }}, socket do
    socket
    |> assign(:q, q)
    |> filter_issues
    |> return_noreply
  end

  defp filter_issues socket do
    socket
    |> assign(:filtered_issues,
      (Enum.filter socket.assigns.state.issues,
        &(should_show? socket.assigns.state, &1, socket.assigns.q))
    )
  end

  defp should_show? state, issue, q do

    selected_secondary_contexts = state.selected_secondary_contexts

    unless length(selected_secondary_contexts) > 0 do
      true
    else
      issues_contexts = Enum.map issue.contexts, &(&1.context.id)
      diff = selected_secondary_contexts -- issues_contexts
      length(diff) == 0
    end and (q == "" or search_matches? issue.title, q)
  end

  defp search_matches? title, q do
    tokenized =
      (
        title
        |> String.downcase
        |> String.split(" ")
      )

    q = String.downcase q
    not is_nil Enum.find tokenized, &(String.starts_with? &1, q)
  end
end
