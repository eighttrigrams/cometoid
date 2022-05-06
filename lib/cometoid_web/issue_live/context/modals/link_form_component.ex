defmodule CometoidWeb.IssueLive.Context.Modals.LinkFormComponent do
  use CometoidWeb, :live_component

  alias Cometoid.Repo.Tracker
  alias CometoidWeb.IssueLive.Context.Modals.LinkFormComponent

  def update assigns, socket do
    {:ok, socket |> assign(assigns)}
  end

  def handle_event "save", params , socket do
    secondary_contexts_ids = case params do
      %{ "links" => %{ "secondary_contexts" => ids }} ->
        Enum.map(ids, fn id -> to_int id end)
      _ -> []
    end
    primary_context = socket.assigns.state.selected_context
    case Tracker.link_contexts primary_context, secondary_contexts_ids do
      {:ok, context} ->
        send self(), {:after_edit_form_save, %{ context_id: context.id }}
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket}
    end
    {:noreply, socket}
  end

  def get_contexts state do
    contexts = state.contexts ++ if state.selected_view == "People" do
      []
    else
      Tracker.list_contexts "People"
    end
    contexts
    |> Enum.filter(fn ctx -> ctx.id != state.selected_context.id end)
    |> Enum.sort_by(fn ctx -> String.downcase(ctx.title) end)
    |> Enum.map(fn ctx -> {ctx.title, ctx.id} end)
  end
end
