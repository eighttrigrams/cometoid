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
    socket
    |> assign(:q, q)
    |> assign(:filtered_contexts, (Enum.filter socket.assigns.state.contexts, &(should_show? &1, q)))
    |> return_noreply
  end

  def handle_event "select", _, socket do
    if 1 == length socket.assigns.filtered_contexts do
      send self(), {:select_context, (List.first socket.assigns.filtered_contexts).id}
    end
    socket
    |> return_noreply
  end

  defp should_show? context, q do
    search_matches? context, q
  end

  defp search_matches? %{title: title, short_title: short_title, tags: tags}, q do
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
end
