defmodule CometoidWeb.IssueLive.Taskbar.TaskbarComponent do
  use CometoidWeb, :live_component

  alias CometoidWeb.IssueLive.Taskbar.FilterModalComponent

  def get_contexts state do
    if state.selected_context do # TODO review

      # TODO review possible duplication with taskbarcomponent
      state.selected_context.secondary_contexts
      |> Enum.map(fn ctx -> {ctx.id, ctx.title, ctx.short_title} end)
      |> Enum.filter(fn {id, _title, _short_title} -> id in state.selected_secondary_contexts end)
      |> Enum.sort_by(fn {id, _, _} -> id end)
      |> Enum.take(4)
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
