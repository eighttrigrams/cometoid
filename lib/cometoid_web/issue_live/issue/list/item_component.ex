defmodule CometoidWeb.IssueLive.Issue.List.ItemComponent do
  use CometoidWeb, :live_component
  import CometoidWeb.Helpers

  alias CometoidWeb.IssueLive.Issue.List.ActionsComponent
  alias CometoidWeb.IssueLive.Issue.List.BadgesComponent

  def get_highlight issue, filtered_issues, state do
    if state.issue_search_active and 1 == length filtered_issues do 'selected-item-color' end
  end
end
