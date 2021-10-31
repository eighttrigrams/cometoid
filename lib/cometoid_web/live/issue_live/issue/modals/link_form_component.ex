defmodule CometoidWeb.IssueLive.Issue.Modals.LinkFormComponent do
  use CometoidWeb, :live_component

  alias Cometoid.Repo.Tracker

  def handle_event "select_context_type", %{ "target" => context_type }, socket do
    {:noreply, socket |> assign(:link_form_selected_context_type, context_type )}
  end

  def update assigns, socket do
    ctxs = Enum.flat_map(assigns.state.context_types,
      fn context_type ->
        ctxs = list_contexts context_type
        Enum.map(ctxs, fn {_title, id} ->
          {id, is_checked(assigns.state.selected_issue, id)} end)
      end)
      |> Enum.into(%{})

    links = ctxs
    {:ok, socket |> assign(:links, links) |> assign(:state, assigns.state)}
  end

  def handle_event "change", %{ "links" => links }, socket do
    {:noreply, socket |> assign(:links, Map.merge(socket.assigns.links, links))}
  end

  def handle_event "save", _, socket do

    selected_contexts = extract_from socket.assigns.links
    selected_contexts = Enum.map selected_contexts,
      fn c -> {id, ""} = Integer.parse(c); id end

    if length(selected_contexts) == 0 do
      {:noreply, socket}
    else
      issue = socket.assigns.state.selected_issue
      context_types = socket.assigns.state.context_types ++ ["Person"]

      contexts =
        Tracker.list_contexts
        |> Enum.filter(&(&1.context_type in context_types))

      case Tracker.update_issue_relations(issue, selected_contexts, contexts) do
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

  def list_contexts context_type do
    results = Tracker.list_contexts context_type
    Enum.map results, fn r -> {r.title, Integer.to_string(r.id)} end
  end

  def is_checked issue, context_id do
    {context_id, ""} = Integer.parse context_id
    context_ids = Enum.map issue.contexts, &(&1.context.id)
    if not (is_nil Enum.find context_ids, &(&1 == context_id)) do "true" else "false" end
  end

  defp extract_from params do
    params
    |> Enum.filter(&filter_true/1)
    |> Enum.map(&to_key/1)
  end

  defp filter_true({k, v}), do: v == "true"

  defp to_key({k, _v}), do: k
end
