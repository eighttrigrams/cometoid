defmodule CometoidWeb.IssueLive.Issue.Modals.LinkFormComponent do
  use CometoidWeb, :live_component

  alias Cometoid.Repo.Tracker

  def update assigns, socket do
    state = assigns.state
    links = prepare_links state
    {:ok,
      socket
      |> assign(:links, links)
      |> assign(:state, state)
    }
  end

  def handle_event "change", %{ "links" => links }, socket do
    {:noreply, socket |> assign(:links, Map.merge(socket.assigns.links, links))}
  end

  def handle_event "save", _, socket do

    ids_of_selected_contexts = get_ids_of_selected_contexts socket

    if 0 == length ids_of_selected_contexts do
      {:noreply, socket}
    else
      issue = socket.assigns.state.selected_issue
      views = get_views socket.assigns.state

      case Tracker.update_issue_relations issue, ids_of_selected_contexts do
        {:ok, issue} ->
          send self(), {:after_edit_form_save, issue}
          {:noreply,
           socket |> put_flash(:info, "Issue updated successfully")
          }
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, :changeset, changeset)}
      end
    end
  end

  def get_views state do
    Enum.uniq ["People", state.selected_view]
  end

  def list_selectable_contexts state do
    Enum.map state.selected_context.secondary_contexts,
      fn context -> {context.title, Integer.to_string(context.id)} end
  end

  def list_contexts view do
    contexts = Tracker.list_contexts view
    Enum.map contexts, fn context -> {context.title, Integer.to_string(context.id)} end
  end

  def is_checked issue, context_id do
    {context_id, ""} = Integer.parse context_id
    context_ids = Enum.map issue.contexts, &(&1.context.id)
    if not (is_nil Enum.find context_ids, &(&1 == context_id)) do "true" else "false" end
  end

  defp prepare_links state do
    Enum.flat_map(get_views(state),
    fn view ->
      ctxs = list_contexts view
      Enum.map(ctxs, fn {_title, id} ->
        {id, is_checked(state.selected_issue, id)} end)
    end)
    |> Enum.into(%{})
  end

  defp get_ids_of_selected_contexts socket do
    selected_contexts = extract_from socket.assigns.links
    Enum.map selected_contexts,
      fn c -> {id, ""} = Integer.parse(c); id end
  end

  defp extract_from params do
    params
    |> Enum.filter(&filter_true/1)
    |> Enum.map(&to_key/1)
  end

  defp filter_true({_k, v}), do: v == "true"

  defp to_key({k, _v}), do: k
end
