defmodule CometoidWeb.IssueLive.Issue.List.BadgesComponent do
  use CometoidWeb, :live_component

  def contexts_to_show_as_badges state, issue do
    Enum.filter issue.contexts,
      fn ctx ->
        (is_nil state.selected_context)
        or ctx.context.id != state.selected_context.id
      end
  end
end
