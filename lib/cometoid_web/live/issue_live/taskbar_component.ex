defmodule CometoidWeb.IssueLive.TaskbarComponent do
  # If you generated an app with mix phx.new --live,
  # the line below would be:
  use CometoidWeb, :live_component
  # use Phoenix.LiveComponent

  alias Cometoid.Model.Tracker.Context
  alias CometoidWeb.IssueLive.TaskbarComponent

  def handle_event "toggle_context", %{ "id" => id }, socket do

    {id, ""} = Integer.parse id
    selected_secondary_contexts = socket.assigns.state.selected_secondary_contexts

    selected_secondary_contexts = if Enum.member?(selected_secondary_contexts, id) do
      selected_secondary_contexts -- [id]
    else
      selected_secondary_contexts ++ [id]
    end
    send self(), {:select_secondary_contexts, selected_secondary_contexts}
    {:noreply, socket}
  end

  def is_selected? state, id do
    Enum.member? state.selected_secondary_contexts, id
  end

  def get_contexts state do
    if state.selected_context do
      all_secondary_contexts = state.selected_context.secondary_contexts
      contexts =
      all_secondary_contexts
      |> Enum.map(fn ctx -> {ctx.id, ctx.title} end)
      |> Enum.filter(fn {_id, title} -> title != state.selected_context.title end)
      |> Enum.sort_by(fn {id, _} -> id end)
      |> Enum.take(12)
    else
      []
    end
  end
end
