defmodule CometoidWeb.IssueLive.Context.ListItemComponent do
  use CometoidWeb, :live_component

  alias Cometoid.Model.Tracker.Context

  def should_highlight context, selected_context, contexts, context_search_open do # TODO reduce num params
    if (not is_nil(selected_context) and selected_context.id == context.id)
    or (context_search_open and 1 == length contexts)
    do 'selected-item-color' end
  end

  def show_issues_badge context do
    length(Enum.filter(context.issues, fn issue -> not issue.issue.done end)) > 0
  end

  def show_archived_issues_badge context do
    length(Enum.filter(context.issues, fn issue -> issue.issue.done end)) > 0
  end
end
