defmodule CometoidWeb.IssueLive.Context.ListComponent do
  use CometoidWeb, :live_component

  alias CometoidWeb.IssueLive.Context.ListItemComponent

  @impl true
  def mount socket do
    socket =
      socket
      |> assign(:q, "")
    {:ok, socket}
  end

  @impl true
  def update assigns, socket do
    socket =
      socket
      |> assign(assigns)
      |> assign(:q, "")
    {:ok, socket}
  end

  @impl true
  def handle_event "changes", %{ "context_search" => %{ "q" => q }}, socket do
    socket =
      socket
      |> assign(:q, q)
    {:noreply, socket}
  end

  def should_show context, q do
    String.starts_with? (String.downcase context.title), (String.downcase q)
  end
end
