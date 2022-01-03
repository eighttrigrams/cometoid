defmodule CometoidWeb.IssueLive.ListItemComponent do
  # If you generated an app with mix phx.new --live,
  # the line below would be:
  use CometoidWeb, :live_component
  # use Phoenix.LiveComponent

  def should_show_delete_button state, issue do
    (is_nil state.selected_context)
    or (num_non_tag_contexts state, issue) == 0
  end

  def should_show_unlink_button state, issue do
    not (is_nil state.selected_context)
    and (num_non_tag_contexts state, issue) > 0
  end

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
