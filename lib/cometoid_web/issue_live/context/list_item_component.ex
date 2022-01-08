defmodule CometoidWeb.IssueLive.Context.ListItemComponent do
  use CometoidWeb, :live_component

  alias Cometoid.Model.Tracker.Context

  def show_issues_badge context do
    length(Enum.filter(context.issues, fn issue -> not issue.issue.done end)) > 0
  end

  def show_archived_issues_badge context do
    length(Enum.filter(context.issues, fn issue -> issue.issue.done end)) > 0
  end
end
