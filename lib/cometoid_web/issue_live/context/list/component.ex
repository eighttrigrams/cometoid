defmodule CometoidWeb.IssueLive.Context.List.Component do
  use CometoidWeb, :live_component
  alias CometoidWeb.IssueLive.Context.List.ItemComponent

  def get_contexts state do
    state.selected_context.secondary_contexts
    |> Enum.filter(&(!&1.is_tag?))
  end
end