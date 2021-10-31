defmodule CometoidWeb.IssueLive.Context.Modals.LinkFormComponent do
  use CometoidWeb, :live_component

  alias Cometoid.Repo.Tracker

  def update assigns, socket do
    {:ok, socket |> assign(assigns)}
  end

  def handle_event "save", params , socket do
    children = case params do
      %{ "links" => %{ "children" => ids }} ->
        Tracker.get_contexts_by_ids ids
      _ -> []
    end

    selected_context = socket.assigns.state.selected_context

    case Tracker.update_context(selected_context, %{ "children" => children }) do
      {:ok, context} ->
        send self(), {:after_edit_form_save, %{ context_id: context.id }}
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket}
    end

    {:noreply, socket}
  end
end
