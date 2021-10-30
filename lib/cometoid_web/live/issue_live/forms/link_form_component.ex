defmodule CometoidWeb.IssueLive.Modals.LinkFormComponent do
  use CometoidWeb, :live_component

  alias Cometoid.Repo.Tracker

  def handle_event "select_context_type", %{ "target" => context_type }, socket do
    {:noreply, socket |> assign(:link_form_selected_context_type, context_type )}
  end

  def update assigns, socket do
    ctxs = Enum.flat_map(assigns.state.context_types,
      fn k ->
        ctxs = list_contexts(k)
        Enum.map(ctxs, fn ctx -> {"ctx/#{ctx}", is_checked(assigns.state.selected_issue, ctx)} end)
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
    Enum.map results, fn r -> r.title end
  end

  def is_checked issue, context_title do
    context_titles = Enum.map issue.contexts, &(&1.context.title)
    if not (is_nil Enum.find context_titles, &(&1 == context_title)) do "true" else "false" end
  end

  defp extract_from params do
    params
    |> Enum.filter(&filter_true/1)
    |> Enum.map(&to_key/1)
  end

  defp filter_true({k, v}), do: v == "true"

  defp to_key({k, v}), do: String.replace(k, "ctx/", "")

  defp strip_prefixes({k, v}), do: {k |> String.replace("ctx/", ""), v}
end
