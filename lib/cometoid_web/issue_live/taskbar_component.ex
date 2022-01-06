defmodule CometoidWeb.IssueLive.TaskbarComponent do
  use CometoidWeb, :live_component

  alias CometoidWeb.IssueLive.TaskbarComponent

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
    if state.selected_context do
      all_secondary_contexts = state.selected_context.secondary_contexts

      all_secondary_contexts
      |> Enum.map(fn ctx -> {ctx.id, ctx.title} end)
      |> Enum.filter(fn {_id, title} -> title != state.selected_context.title end)
      |> Enum.sort_by(fn {id, _} -> id end)
      |> Enum.take(12)
    else
      []
    end
  end

  def done_button_disabled? state do
    state.contexts == []
      or length(Enum.flat_map(state.contexts,
        &(&1.issues)) |> Enum.filter(&(&1.issue.done))) == 0
      or
        not is_nil(state.selected_context)
        and length(Enum.filter(state.selected_context.issues, &(&1.issue.done))) == 0
  end
end
