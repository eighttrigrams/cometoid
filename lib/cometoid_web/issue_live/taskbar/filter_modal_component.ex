defmodule CometoidWeb.IssueLive.Taskbar.FilterModalComponent do
  use CometoidWeb, :live_component

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

  def is_selected? state, id do
    Enum.member? state.selected_secondary_contexts, id
  end

  def get_contexts state do
    if state.selected_context do
      all_secondary_contexts = state.selected_context.secondary_contexts

      all_secondary_contexts
      |> Enum.map(fn ctx -> {ctx.id, ctx.title, ctx.short_title} end)
      # TODO don't match by title
      |> Enum.filter(fn {_id, title, _short_title} -> title != state.selected_context.title end)
      |> Enum.sort_by(fn {id, _, _} -> id end)
    else
      []
    end
  end
end
