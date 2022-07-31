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

  def handle_event "select", _, socket do

    send self(), {:select_context}
    
    socket
    |> return_noreply
  end
end
