defmodule CometoidWeb.IssueLive.Index do
  use CometoidWeb, :live_view

  alias Cometoid.CodeAdapter
  alias Cometoid.Repo.Tracker
  alias Cometoid.Repo.Writing
  alias Cometoid.Repo.People
  alias Cometoid.Model.Writing.Text
  alias Cometoid.Model.People.Person
  alias Cometoid.Model.Tracker.Issue
  alias Cometoid.Model.Tracker.Context
  alias CometoidWeb.Theme
  alias CometoidWeb.IssueLive.IssuesMachine

  @impl true
  def mount _params, _session, socket do
    {
      :ok,
      socket
      |> assign(Theme.get)
    }
  end

  def handle_event "switch-theme", %{ "name" => name }, socket do
    Theme.toggle!
    socket
    |> assign(Theme.get)
    |> return_noreply
  end

  @impl true
  def handle_params params, url, socket do
    selected_view = get_selected_view params

    state = %{
      control_pressed: false,
      list_issues_done_instead_open: false,
      selected_secondary_contexts: [],
      selected_view: selected_view
    }
    state = Map.merge socket.assigns, state
    state = IssuesMachine.set_context_properties state
    state = IssuesMachine.set_issue_properties state

    socket = socket
      |> assign(state)
      |> assign(:view, params["view"])
      |> do_query(true)
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def handle_info {:modal_closed}, socket do
    socket
    |> assign(:live_action, :index)
    |> return_noreply
  end

  def handle_info {:select_secondary_contexts, selected_secondary_contexts}, socket do
    socket
    |> assign(:selected_secondary_contexts, selected_secondary_contexts)
    |> return_noreply
  end

  def handle_info {:after_edit_form_save, %{ context_id: context_id }}, socket do

    selected_context = Tracker.get_context! context_id # fetch latest important flag
    state = Map.merge socket.assigns, %{ selected_context: selected_context }
    state = IssuesMachine.set_context_properties_and_keep_selected_context state
    state = IssuesMachine.set_issue_properties state

    socket
    |> assign(state)
    |> push_event(:context_reprioritized, %{ id: selected_context.id })
    |> do_query
  end

  def handle_info {:after_edit_form_save, issue}, socket do

    state =
      IssuesMachine.set_context_properties_and_keep_selected_context socket.assigns
      |> Map.delete(:flash)

    socket
    |> assign(state)
    |> assign(:selected_issue, issue)
    |> do_query
  end

  defp apply_action(socket, :index, _params) do # ?
    socket
    |> assign(:issue, nil)
  end

  def handle_event "keydown", %{ "key" => key }, %{ assigns: %{ live_action: :index } } = socket do
    case key do
      "Escape" -> handle_escape socket
      "n" ->
        socket
        |> assign(:live_action, :new)
        |> assign(:issue, %Issue{})
      "Control" ->
        socket
          |> assign(:control_pressed, true)
      _ ->
        socket
    end
    |> return_noreply
  end

  defp handle_escape socket do
    unless socket.assigns.selected_secondary_contexts == [] do
      socket
      |> assign(:selected_secondary_contexts, [])
    else
      unless is_nil(socket.assigns.selected_context) do
        socket
        |> assign(:selected_context, nil)
        |> do_query(true)
      else
        socket
        |> assign(:selected_issue, nil)
      end
    end
  end

  def handle_event "keyup", %{ "key" => key }, socket do
    case key do
      "Control" ->
        socket
          |> assign(:control_pressed, false)
      _ ->
        socket
    end
    |> return_noreply
  end

  def handle_event("keydown", _params, socket), do: {:noreply, socket}

  @impl true
  def handle_event "delete_issue", %{ "id" => id }, socket do
    state = IssuesMachine.delete_issue to_state(socket), id
    socket
    |> assign(state)
    |> do_query
  end

  def handle_event "edit_issue", id, socket do

    {id, ""} = Integer.parse id

    socket
    |> assign(:issue, Tracker.get_issue!(id))
    |> assign(:live_action, :edit)
    |> return_noreply
  end

  def handle_event "unlink_issue", %{ "target" => id }, socket do
    {id, ""} = Integer.parse id
    state = IssuesMachine.unlink_issue to_state(socket), id
    socket
    |> assign(state)
    |> push_event(:issue_reprioritized, %{ id: id })
    |> do_query
  end

  def handle_event "link_issue", %{ "target" => id }, socket do
    socket
    |> assign(:selected_issue, Tracker.get_issue!(id))
    |> assign(:live_action, :link)
    |> return_noreply
  end

  def handle_event "edit_issue_description", _, socket do
    socket
    |> assign(:issue, Tracker.get_issue!(socket.assigns.selected_issue.id))
    |> assign(:live_action, :describe)
    |> return_noreply
  end

  def handle_event "create_new_issue", params, socket do
    socket
    |> assign(:issue, %Issue{})
    |> assign(:live_action, :new)
    |> return_noreply
  end

  def handle_event "jump_to_context",
      %{
        "target_context_id" => target_context_id,
        "target_issue_id" => target_issue_id
      },
      socket do

    {target_context_id, ""} = Integer.parse target_context_id
    {target_issue_id, ""} = Integer.parse target_issue_id

    state = IssuesMachine.jump_to_context socket.assigns,
      target_context_id, target_issue_id

    socket
    |> assign(state)
    |> push_event(:issue_reprioritized, %{ id: target_issue_id })
    |> push_event(:context_reprioritized, %{ id: target_context_id })
    |> do_query
  end

  def handle_event "create_new_context", %{ "view" => view }, socket do

    entity = case view do
      "People" -> %Person{}
      _ -> %Context{}
    end

    socket
    |> assign(:edit_entity, entity)
    |> assign(:live_action, :new_context)
    |> assign(:edit_selected_view, view)
    |> return_noreply
  end

  def handle_event "delete_context", %{ "id" => id }, socket do
    context = Tracker.get_context!(id)
    {:ok, _} = Tracker.delete_context(context)

    state =
      socket.assigns
      |> IssuesMachine.set_context_properties
      |> IssuesMachine.set_issue_properties

    socket
    |> assign(state)
    |> return_noreply
  end

  def handle_event "right_click", _, socket do
    socket
    |> assign(:control_pressed, true)
    |> return_noreply
  end

  def handle_event "mouse_leave", _, socket do
    socket
    |> assign(:control_pressed, false)
    |> return_noreply
  end

  def handle_event "edit_context_description", _, socket do
    context = Tracker.get_context! socket.assigns.selected_context.id
    entity = case context.view do
      "People" -> People.get_person! context.person.id
      _ -> context
    end
    socket
    |> assign(:edit_entity, entity)
    |> assign(:live_action, :describe_context)
    |> return_noreply
  end

  def handle_event "edit_context", id, socket do

    {id, ""} = Integer.parse id

    context = Tracker.get_context! id
    entity = case context.view do
      "People" -> People.get_person! context.person.id
      _ -> context
    end

    socket
    |> assign(:edit_selected_view, context.view)
    |> assign(:edit_entity, entity)
    |> assign(:live_action, :edit_context)
    |> return_noreply
  end

  def handle_event "select_context", %{ "id" => id }, socket do
    {id, ""} = Integer.parse id
    state = IssuesMachine.select_context to_state(socket), id
    socket
    |> assign(state)
    |> assign(:selected_secondary_contexts, [])
    |> do_query
  end

  def handle_event "link_context", %{ "id" => id }, socket do
    {id, ""} = Integer.parse id
    state = IssuesMachine.select_context to_state(socket), id
    socket
    |> assign(state)
    |> assign(:live_action, :link_context)
    |> return_noreply
  end

  def handle_event "reprioritize_context", %{ "id" => id }, socket do
    {id, ""} = Integer.parse id
    state =
      socket.assigns
      |> IssuesMachine.select_context!(id)

    socket
    |> assign(state)
    |> push_event(:context_reprioritized, %{ id: state.selected_context.id })
    |> do_query
  end

  def handle_event "show_open_issues", params, socket do
    socket
    |> assign(:list_issues_done_instead_open, false)
    |> do_query
  end

  def handle_event "show_closed_issues", params, socket do
    socket
    |> assign(:list_issues_done_instead_open, true)
    |> do_query
  end

  def handle_event "select_issue", %{ "target" => id }, socket do
    selected_issue = Tracker.get_issue! id
    socket
    |> assign(:selected_issue, selected_issue)
    |> return_noreply
  end

  def handle_event "reprioritize_issue", %{ "id" => id }, socket do
    Tracker.get_issue!(id)
    |> Tracker.update_issue_updated_at
    selected_issue = Tracker.get_issue! id
    socket
    |> push_event(:issue_reprioritized, %{ id: id })
    |> assign(:selected_issue, selected_issue)
    |> do_query
  end

  def handle_event "toggle_context_important", %{ "target" => id }, socket do

    context = Tracker.get_context! id
    socket = socket |> assign(:selected_context, context)
    Tracker.update_context(context, %{ "important" => !context.important })

    socket
    |> assign(IssuesMachine.set_context_properties_and_keep_selected_context(to_state(socket)))
    |> push_event(:context_reprioritized, %{ id: id })
    |> do_query
  end

  def handle_event "toggle_issue_important", %{ "target" => id }, socket do

    selected_issue = Tracker.get_issue! id
    Tracker.update_issue2(selected_issue, %{ "important" => !selected_issue.important })

    socket
    |> assign(IssuesMachine.set_context_properties_and_keep_selected_context(to_state(socket)))
    |> assign(:selected_issue, selected_issue)
    |> push_event(:issue_reprioritized, %{ id: id })
    |> do_query
  end

  def handle_event "unarchive", %{ "target" => id }, socket do
    state = IssuesMachine.unarchive_issue(to_state(socket), id)
    socket
    |> assign(state)
    |> push_event(:issue_reprioritized, %{ id: id })
    |> do_query
  end

  def handle_event "archive", %{ "target" => id }, socket do
    socket
    |> assign(IssuesMachine.archive_issue(to_state(socket), id))
    |> do_query
  end

  defp do_query socket do
    do_query socket, false
  end
  defp do_query socket, suppress_return do

    socket = socket
    |> assign(IssuesMachine.do_query(socket.assigns |> Map.delete(:flash)))
    |> assign(:live_action, :index)

    if suppress_return do
      socket
    else
      socket |> return_noreply
    end
  end

  defp get_selected_view params do
    if Map.has_key?(params, "view") do
      params["view"]
    end
  end

  def should_show_issues_list_in_contexts_view nil, _ do
    false
  end

  # TODO only used in contexts view, so should be placed there
  def should_show_issues_list_in_contexts_view selected_context, list_issues_done_instead_open do
    issues = if list_issues_done_instead_open do
      Enum.filter selected_context.issues, &(&1.issue.done)
    else
      Enum.filter selected_context.issues, &(!&1.issue.done)
    end
    length(issues) > 0
  end

  defp to_state(socket), do: socket.assigns |> Map.delete(:flash)

  defp return_noreply(socket, flash_type, flash_value), do: {:noreply, socket |> put_flash(flash_type, flash_value)}

  defp return_noreply(socket), do: {:noreply, socket |> Map.delete(:flash) }
end
