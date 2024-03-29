defmodule CometoidWeb.IssueLive.Issue.List.Component do
  use CometoidWeb, :live_component

  alias CometoidWeb.IssueLive.Issue.List.ItemComponent

  @impl true
  def mount socket do
    socket
    |> assign(:q, "")
    |> assign(:state, %{})
    |> return_ok
  end

  @impl true
  def update assigns, socket do
    if socket.assigns.state != assigns.state 
      or assigns.was_last_called_handler_select_context? do

      socket
      |> assign(assigns)
      |> assign(:q, "")
      |> maybe_focus_first_issue
    else
      socket 
    end
    |> return_ok
  end

  @impl true
  def handle_event "changes", %{ "issue_search" => %{ "q" => q }}, socket do

    send self(), {:search_issues, :q, q}
    
    socket
    |> assign(:q, q)
    |> return_noreply
  end

  def handle_event "select", _, socket do
    
    send self(), {:select_issue}
    
    socket
    |> return_noreply
  end

  defp maybe_focus_first_issue socket do
    if socket.assigns.was_last_called_handler_select_context? and length(socket.assigns.state.issues) > 0 do
      socket
      |> push_event(:issue_refocus, %{ id: List.first(socket.assigns.state.issues).id })
    else
      socket
    end
  end
end
