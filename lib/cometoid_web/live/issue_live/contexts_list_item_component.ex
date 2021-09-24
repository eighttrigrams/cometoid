defmodule CometoidWeb.IssueLive.ContextsListItemComponent do
  # If you generated an app with mix phx.new --live,
  # the line below would be:
  use CometoidWeb, :live_component
  # use Phoenix.LiveComponent

  def show_issues_badge context do
    length(Enum.filter(context.issues, fn issue -> not issue.done end)) > 0
  end

  def show_archived_issues_badge context do
    length(Enum.filter(context.issues, fn issue -> issue.done end)) > 0
  end
end
