defmodule CometoidWeb.IssueLive.Context.Overview.Component do
  use CometoidWeb, :live_component

  alias CometoidWeb.IssueLive.Context.Overview.ItemComponent
  alias CometoidWeb.Helpers

  @impl true
  def mount socket do
    socket
    |> assign(:q, "")
    |> return_ok
  end

  @impl true
  def update assigns, socket do
    socket
    |> assign(assigns)
    |> assign(:q, "")
    |> return_ok
  end

  @impl true
  def handle_event "changes", %{ "context_search" => %{ "q" => q }}, socket do

    send self(), {:search_contexts, :q, q}
    
    socket
    |> return_noreply
  end

  # TODO review
  def handle_event "select", _, socket do
    if 1 == length socket.assigns.state.contexts do
      send self(), {:select_context, (List.first socket.assigns.state.contexts).id}
    end
    socket
    |> return_noreply
  end
end
