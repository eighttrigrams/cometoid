defmodule CometoidWeb.IssueLive.Context.Overview.ItemComponent do
  use CometoidWeb, :live_component

  alias Cometoid.Model.Tracker.Context

  def get_highlight context, contexts, state do
    if (not is_nil(state.selected_context) 
      and is_nil(state.selected_issue)
      and state.selected_context.id == context.id)
    or (state.search.context_search_active and 1 == length contexts)
    do 'selected-item-color' end
  end
end
