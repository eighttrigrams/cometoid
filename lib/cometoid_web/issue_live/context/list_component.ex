defmodule CometoidWeb.IssueLive.Context.ListComponent do
  use CometoidWeb, :live_component

  alias CometoidWeb.IssueLive.Context.ListItemComponent

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
    socket
    |> assign(:q, q)
    |> assign(:contexts, (Enum.filter socket.assigns.contexts, &(should_show &1, q)))
    |> return_noreply
  end

  defp should_show context, q do
    String.starts_with? (String.downcase context.title), (String.downcase q)
  end
end
