defmodule CometoidWeb.IssueLive.Context.Overview.ItemComponent do
  use CometoidWeb, :live_component

  alias Cometoid.Model.Tracker.Context

  def get_highlight context, filtered_contexts, state do
    if (not is_nil(state.selected_context) and state.selected_context.id == context.id)
    or (state.context_search_active and 1 == length filtered_contexts)
    do 'selected-item-color' end
  end

  def show_issues_badge context do
    length(Enum.filter(context.issues, fn issue -> not issue.issue.done end)) > 0
  end

  def show_archived_issues_badge context do
    length(Enum.filter(context.issues, fn issue -> issue.issue.done end)) > 0
  end
end
