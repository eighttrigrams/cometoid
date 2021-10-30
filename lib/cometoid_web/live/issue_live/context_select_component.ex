defmodule CometoidWeb.IssueLive.ContextSelectComponent do
  use CometoidWeb, :live_component

  alias CometoidWeb.IssueLive.ContextSelectComponent

  def handle_event "toggle_context", %{ "title" => title }, socket do

    selected_secondary_contexts = socket.assigns.state.selected_secondary_contexts

    selected_secondary_contexts = if Enum.member?(selected_secondary_contexts, title) do
      selected_secondary_contexts -- [title]
    else
      selected_secondary_contexts ++ [title]
    end
    send self(), {:select_secondary_contexts, selected_secondary_contexts}
    {:noreply, socket}
  end

  def is_selected? state, context_title do
    Enum.member? state.selected_secondary_contexts, context_title
  end

  def get_contexts state do
    all_children = Cometoid.Repo.Tracker.get_all_children(state.selected_context.id)
    contexts =
    all_children
    |> Enum.map(fn ctx -> ctx.title end)
    |> Enum.filter(fn title -> title != state.selected_context.title end)
    |> Enum.sort
  end
end
