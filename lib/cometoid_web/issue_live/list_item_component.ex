defmodule CometoidWeb.IssueLive.ListItemComponent do
  # If you generated an app with mix phx.new --live,
  # the line below would be:
  use CometoidWeb, :live_component
  # use Phoenix.LiveComponent

  def should_show_delete_button state, issue do
    (is_nil state.selected_context)
    or (length issue.contexts) == 1
  end

  def should_show_unlink_button state, issue do
    not (is_nil state.selected_context)
    and (length issue.contexts) > 1
  end

  def contexts_to_show_as_badges state, contexts do
    Enum.filter contexts,
      fn ctx ->
        (is_nil state.selected_context)
        or ctx.context.title != state.selected_context.title
      end
  end
end
