defmodule CometoidWeb.IssueLive.ContextSelectComponent do
  use CometoidWeb, :live_component

  alias CometoidWeb.IssueLive.ContextSelectComponent

  def handle_event "toggle_context", %{ "id" => id }, socket do

    {id, ""} = Integer.parse id
    selected_secondary_contexts = socket.assigns.state.selected_secondary_contexts

    selected_secondary_contexts = if Enum.member?(selected_secondary_contexts, id) do
      selected_secondary_contexts -- [id]
    else
      selected_secondary_contexts ++ [id]
    end
    send self(), {:select_secondary_contexts, selected_secondary_contexts}
    {:noreply, socket}
  end

  def is_selected? state, id do
    Enum.member? state.selected_secondary_contexts, id
  end

  def get_contexts state do
    all_children = state.selected_context.children
    contexts =
    all_children
    |> Enum.map(fn ctx -> {ctx.id, ctx.title} end)
    |> Enum.filter(fn {_id, title} -> title != state.selected_context.title end)
    |> Enum.sort_by(fn {id, _} -> id end)
  end
end
