defmodule CometoidWeb.IssueLive.ListComponent do
  # If you generated an app with mix phx.new --live,
  # the line below would be:
  use CometoidWeb, :live_component
  # use Phoenix.LiveComponent

  alias CometoidWeb.IssueLive.ListComponent
  alias CometoidWeb.IssueLive.ListItemComponent

  def get_issues state do
    all_issues = elem(state.issues, 0) ++ elem(state.issues, 1)
    Enum.filter all_issues, &(should_show?(state, &1))
  end

  defp should_show? state, issue do

    selected_secondary_contexts = state.selected_secondary_contexts

    unless length(selected_secondary_contexts) > 0 do
      true
    else
      issues_contexts = Enum.map issue.contexts, &(&1.context.title)
      diff = selected_secondary_contexts -- issues_contexts
      length(diff) == 0
    end
  end
end
