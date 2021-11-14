defmodule CometoidWeb.IssueLive.ListItemComponent do
  # If you generated an app with mix phx.new --live,
  # the line below would be:
  use CometoidWeb, :live_component
  # use Phoenix.LiveComponent

  def should_show_delete_button state, issue do
    is_nil(state.selected_context)
    or length(issue.contexts) == 1
  end
end
