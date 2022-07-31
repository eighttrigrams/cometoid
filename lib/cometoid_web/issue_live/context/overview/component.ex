defmodule CometoidWeb.IssueLive.Context.Overview.Component do
  use CometoidWeb, :live_component

  alias CometoidWeb.IssueLive.Context.Overview.ItemComponent
  alias CometoidWeb.Helpers

  @impl true
  def mount socket do
    socket
    |> assign(:q, "")
    |> assign(:filtered_contexts, [])
    |> return_ok
  end

  # TODO get rid of filtered_contexts

  @impl true
  def update assigns, socket do
    socket
    |> assign(assigns)
    |> assign(:q, "")
    |> assign(:filtered_contexts, assigns.state.contexts)
    |> return_ok
  end

  @impl true
  def handle_event "changes", %{ "context_search" => %{ "q" => q }}, socket do

    send self(), {:search_contexts, :q, q}
    
    socket
    |> return_noreply
  end

  def handle_event "select", _, socket do
    if 1 == length socket.assigns.filtered_contexts do
      send self(), {:select_context, (List.first socket.assigns.filtered_contexts).id}
    end
    socket
    |> return_noreply
  end
end
