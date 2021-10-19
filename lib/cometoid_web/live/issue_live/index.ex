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
  alias Cometoid.Editor
  alias CometoidWeb.Theme
  alias CometoidWeb.IssueLive.IssuesMachine

  @impl true
  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(Theme.get)
    }
  end

  def handle_event "switch-theme", %{ "name" => name }, socket do
    Theme.toggle
    socket
    |> assign(Theme.get)
    |> return_noreply
  end

  def render(assigns) do
    if (is_nil(assigns[:contexts_view]) or assigns.contexts_view == false) do
      Phoenix.View.render(CometoidWeb.IssueLive.IssuesView, "issues_view.html", assigns)
    else
      Phoenix.View.render(CometoidWeb.IssueLive.ContextsView, "contexts_view.html", assigns)
    end
  end

  @impl true
  def handle_params params, url, socket do
    contexts_view = should_show_contexts_view params
    context_types = get_context_types params
    all_issue_types = Application.fetch_env!(:cometoid, :issue_types) |> Map.take(context_types ++ ["Person"])

    state = %{
      control_pressed: false,
      all_issue_types: all_issue_types,
      context_types: context_types,
      contexts_view: contexts_view,
      list_issues_done_instead_open: false,
      selected_context_type: nil
    }
    state = Map.merge socket.assigns, state # TODO swap params and use |>
    state = IssuesMachine.set_context_properties state, true

    state = if not contexts_view and is_nil(state.selected_context) do
      state = Map.merge state, %{ contexts_view: true }
    else
      state
    end

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

  def handle_info {:after_edit_form_save, %{ context_id: context_id }}, socket do

    selected_context = Tracker.get_context! context_id # fetch latest important flag
    state = IssuesMachine.set_context_properties socket.assigns, selected_context.important
    state = IssuesMachine.set_issue_properties state

    socket
    |> assign(state)
    |> do_query
  end

  def handle_info {:after_edit_form_save, issue}, socket do

    state =
      IssuesMachine.set_context_properties socket.assigns
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

  def handle_event "keydown", %{ "key" => key }, %{ assigns: %{ live_action: :index, issue_types: issue_types }} = socket do
    case key do
      "Escape" ->
        if length(issue_types) == 1, do: socket, else:
          socket
          |> assign(:selected_issue_type, nil)
          |> do_query(true)
      "n" ->
        if is_nil(socket.assigns[:selected_issue_type]) do
          socket
        else
          socket
          |> assign(:live_action, :new)
          |> assign(:issue, %Issue{})
        end
      "Control" ->
        socket
          |> assign(:control_pressed, true)
      _ ->
        socket
    end
    |> return_noreply
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

  def handle_event "toggle_mode", _params, socket do
    state = socket.assigns
    state =
      state
      |> Map.merge(%{ contexts_view: !state.contexts_view })
      |> IssuesMachine.set_context_properties(true)
      |> IssuesMachine.set_issue_properties
    socket
    |> assign(state)
    |> do_query
  end

  def handle_event "select_issue_type", %{ "target" => issue_type }, socket do
    socket
    |> assign(:selected_issue_type, issue_type)
    |> put_flash(:info, nil)
    |> do_query
  end

  def handle_event "unselect_issue_type", _params, socket do
    socket
    |> assign(:selected_issue_type, nil)
    |> put_flash(:info, nil)
    |> do_query
  end

  def handle_event "edit_issue", %{ "target" => id }, socket do
    socket
    |> assign(:issue, Tracker.get_issue!(id))
    |> assign(:live_action, :edit)
    |> return_noreply
  end

  def handle_event "link_issue", %{ "target" => id }, socket do
    socket
    |> assign(:issue, Tracker.get_issue!(id))
    |> assign(:live_action, :link)
    |> return_noreply
  end

  def handle_event "edit_issue_description", %{ "target" => id }, socket do
    socket
    |> assign(:issue, Tracker.get_issue!(id))
    |> assign(:live_action, :describe)
    |> return_noreply
  end

  def handle_event "create_new_issue", params, socket do

    if socket.assigns.selected_issue_type do
      socket
      # |> assign(:page_title, "New Issue")
      |> assign(:issue, %Issue{})
      |> assign(:live_action, :new)
      |> return_noreply
    else
      socket
      |> return_noreply(:error, "No issue type selected")
    end
  end

  def handle_event "create_new_context", %{ "context_type" => context_type }, socket do

    entity = case context_type do
      "Person" -> %Person{}
      _ -> %Context{}
    end

    socket
    |> assign(:edit_entity, entity)
    |> assign(:live_action, :new_context)
    |> assign(:edit_selected_context_type, context_type)
    |> return_noreply
  end

  # TODO check duplication with context_live/index
  def handle_event "delete_context", %{ "id" => id }, socket do
    context = Tracker.get_context!(id)
    {:ok, _} = Tracker.delete_context(context)

    # Editor.delete_context context
    # {:noreply, assign(socket, :contexts, list_contexts())}
    state =
      socket.assigns
      |> IssuesMachine.set_context_properties(true)
      |> IssuesMachine.set_issue_properties

    socket
    |> assign(state)
    |> return_noreply
  end

  def handle_event "edit_context", %{ "target" => id }, socket do
    context = Tracker.get_context! id
    entity = case context.context_type do
      "Person" -> People.get_person! context.person.id
      _ -> context
    end

    socket
    |> assign(:edit_selected_context_type, context.context_type)
    |> assign(:edit_entity, entity)
    |> assign(:live_action, :edit_context)
    |> return_noreply
  end

  def handle_event "select_context_type", %{ "context_type" => context_type }, socket do

    selected_context_type = if context_type != "none", do: context_type

    state = socket.assigns
      |> Map.merge(%{ selected_context_type: selected_context_type })
      |> IssuesMachine.set_context_properties(true)
      |> IssuesMachine.set_issue_properties

    socket
    |> assign(state)
    |> do_query
  end

  def handle_event "select_context", %{ "context" => context } = params, socket do

    state = if (is_nil(params["no_update"]) and params["no_update"] != "true") and socket.assigns.control_pressed do
      IssuesMachine.select_context! socket.assigns, context
    else
      IssuesMachine.select_context socket.assigns, context
    end
    |> IssuesMachine.set_issue_properties

    socket
    |> assign(state)
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
    if socket.assigns.control_pressed do
      Tracker.get_issue!(id)
      |> Tracker.update_issue_updated_at
      selected_issue = Tracker.get_issue! id
      socket
      |> assign(:selected_issue, selected_issue)
      |> do_query
    else
      selected_issue = Tracker.get_issue! id
      socket
      |> assign(:selected_issue, selected_issue)
      |> return_noreply
    end
  end

  def handle_event "open_context_in_editor", %{ "target" => id }, socket do
    selected_context = Tracker.get_context! id
    Editor.open_context selected_context
    socket
    |> assign(:selected_issue, nil)
    |> return_noreply
  end

  def handle_event "open_issue_in_editor", %{ "target" => id }, socket do
    selected_issue = Tracker.get_issue! id
    Tracker.update_issue2(selected_issue, %{ "has_markdown" => true })
    selected_issue = Tracker.get_issue! id
    contents = Editor.open_issue selected_issue
    if String.length(contents) > 0 do
      Tracker.update_issue2(selected_issue, %{ "markdown" => contents })
    end
    selected_issue = Tracker.get_issue! id

    socket
    |> assign(:selected_issue, selected_issue)
    |> do_query
  end

  def handle_event "toggle_context_important", %{ "target" => id }, socket do

    context = Tracker.get_context! id
    Tracker.update_context(context, %{ "important" => !context.important })

    socket
    |> assign(IssuesMachine.set_context_properties(to_state(socket)))
    |> do_query
  end

  def handle_event "toggle_issue_important", %{ "target" => id }, socket do

    issue = Tracker.get_issue! id
    Tracker.update_issue2(issue, %{ "important" => !issue.important })

    socket
    |> assign(IssuesMachine.set_context_properties(to_state(socket)))
    |> do_query
  end

  def handle_event "unarchive", %{ "target" => id }, socket do
    issue = Tracker.get_issue! id
    Tracker.update_issue2(issue, %{ "done" => false })

    socket
    |> assign(IssuesMachine.set_context_properties(to_state(socket)))
    |> assign(:list_issues_done_instead_open, false)
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

  defp get_context_types params do
    if Map.has_key?(params, "context_types") do
      String.split(params["context_types"], "_")
    end
  end

  def should_show_issues_list_in_contexts_view nil, _ do
    false
  end

  defp should_show_contexts_view params do
    view = Enum.find(Application.fetch_env!(:cometoid, :context_types), fn ct -> ct.name == params["view"] end)
    ((!is_nil(params["alternative_view"]) && params["alternative_view"] == "true")
      or (!is_nil(view[:alternative_view] && view.alternative_view == true)))
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
