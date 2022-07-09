defmodule CometoidWeb.IssueLive.Issue.List.Component do
  use CometoidWeb, :live_component

  alias CometoidWeb.Helpers
  alias CometoidWeb.IssueLive.Issue.List.ItemComponent

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
    |> maybe_focus_first_issue
    |> return_ok
  end

  @impl true
  def handle_event "changes", %{ "issue_search" => %{ "q" => q }}, socket do
    socket
    |> assign(:q, q)
    |> filter_issues
    |> return_noreply
  end

  def handle_event "select", _, socket do
    if 1 == length socket.assigns.filtered_issues do
      send self(), {:select_issue, (List.first socket.assigns.filtered_issues).id}
    end
    socket
    |> return_noreply
  end

  def search_matches? %{title: title, short_title: short_title, tags: tags}, q do
    short_title = String.downcase(short_title || "")
    tags = String.downcase(tags)
    
    tokenized =
      (
        title
        |> Helpers.demarkdownify
        |> String.downcase
        |> String.split(" ")
      ) 
      ++ String.split(short_title, " ")
      ++ String.split(tags, " ")

    qs = q
      |> String.downcase
      |> String.split(" ")
      |> Enum.filter(&(&1 != ""))

    Enum.reduce qs, true, fn q, acc ->
      acc && !is_nil(Enum.find tokenized, &(String.starts_with? &1, q))
    end
  end

  defp filter_issues socket do
    socket
    |> assign(:filtered_issues,
      (Enum.filter socket.assigns.state.issues,
        &(should_show? socket.assigns.state, &1, socket.assigns.q))
    )
  end

  defp maybe_focus_first_issue socket do
    if socket.assigns.was_last_called_handler_select_context? and length(socket.assigns.filtered_issues) > 0 do
      socket
      |> push_event(:issue_refocus, %{ id: List.first(socket.assigns.filtered_issues).id })
    else
      socket
    end
  end

  defp should_show? state, issue, q do

    selected_secondary_contexts = state.selected_secondary_contexts

    unless length(selected_secondary_contexts) > 0 do
      true
    else
      issues_contexts = Enum.map issue.contexts, &(&1.context.id)
      diff = selected_secondary_contexts -- issues_contexts
      length(diff) == 0
    end and (q == "" or search_matches? issue, q)
  end
end
