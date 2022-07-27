defmodule CometoidWeb.IssueLive.Issue.List.ItemComponent do
  use CometoidWeb, :live_component
  import CometoidWeb.Helpers

  alias CometoidWeb.IssueLive.Issue.List.ActionsComponent
  alias CometoidWeb.IssueLive.Issue.List.BadgesComponent

  def get_highlight _issue, state do
    if state.search.issue_search_active and 1 == length state.issues do 'selected-item-color' end
  end
end
