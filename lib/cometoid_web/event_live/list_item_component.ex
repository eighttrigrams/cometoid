defmodule CometoidWeb.EventLive.ListItemComponent do
  use CometoidWeb, :live_component

  alias Cometoid.Repo.Tracker

  def get_contexts_to_show issue do
    issue = Tracker.get_issue! issue.id
    issue.contexts
  end
end
