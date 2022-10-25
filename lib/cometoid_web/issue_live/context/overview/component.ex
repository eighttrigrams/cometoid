defmodule CometoidWeb.IssueLive.Context.Overview.Component do
  use CometoidWeb, :live_component

  alias CometoidWeb.IssueLive.Context.Overview.ItemComponent

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

  def handle_event "toggle_context", %{ "id" => id }, socket do

    id = to_int id
    selected_secondary_contexts = socket.assigns.state.selected_secondary_contexts

    selected_secondary_contexts = if Enum.member?(selected_secondary_contexts, id) do
      selected_secondary_contexts -- [id]
    else
      selected_secondary_contexts ++ [id]
    end
    send self(), {:select_secondary_contexts, selected_secondary_contexts}
    {:noreply, socket}
  end

  def num_related_issues state, secondary_context do
    length Enum.filter state.issues, 
      fn issue -> 
        secondary_context.id in (Enum.map issue.contexts, fn relation -> relation.context.id end) 
      end
  end

  def is_selected? state, id do
    Enum.member? state.selected_secondary_contexts, id
  end
end
