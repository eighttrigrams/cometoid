defmodule CometoidWeb.IssueLive.Taskbar.TaskbarComponent do
  use CometoidWeb, :live_component

  alias CometoidWeb.IssueLive.Taskbar.FilterModalComponent

  def get_contexts state do
    if state.selected_context do

      state.selected_context.secondary_contexts
      |> Enum.map(fn ctx -> {ctx.id, ctx.title, ctx.short_title} end)
      |> Enum.filter(fn {id, _title, _short_title} -> id in state.selected_secondary_contexts end)
      |> Enum.sort_by(fn {id, _, _} -> id end)
      |> Enum.take(4)
    else
      []
    end
  end

  def get_sort_symbol state do
    cond do
      is_nil(state.selected_context.search_mode) or state.selected_context.search_mode == 0 -> "down-alt"
      state.selected_context.search_mode == 1 -> "alpha-down"
      state.selected_context.search_mode == 2 -> "alpha-up-alt"
    end
  end
end
