defmodule CometoidWeb.IssueLive.Issue.ListItemComponent do
  # If you generated an app with mix phx.new --live,
  # the line below would be:
  use CometoidWeb, :live_component
  # use Phoenix.LiveComponent

  def contexts_to_show_as_badges state, issue do
    Enum.filter issue.contexts,
      fn ctx ->
        (is_nil state.selected_context)
        or ctx.context.id != state.selected_context.id
      end
  end

  defp num_non_tag_contexts state, issue do
    length Enum.filter issue.contexts, &(not &1.context.is_tag? and &1.context.id != state.selected_context.id)
  end
end
