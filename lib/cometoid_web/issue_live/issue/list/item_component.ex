defmodule CometoidWeb.IssueLive.Issue.List.ItemComponent do
  use CometoidWeb, :live_component
  import CometoidWeb.Helpers

  alias CometoidWeb.IssueLive.Issue.List.ActionsComponent
  alias CometoidWeb.IssueLive.Issue.List.BadgesComponent

  defp num_non_tag_contexts state, issue do
    length Enum.filter issue.contexts, &(not &1.context.is_tag? and &1.context.id != state.selected_context.id)
  end
end
