defmodule CometoidWeb.IssueLive.IssuesMachineTest do
  use Cometoid.RepoCase

  alias Cometoid.Repo.Tracker
  alias Cometoid.Model.Tracker.Context
  alias Cometoid.Model.Tracker.Issue
  alias CometoidWeb.IssueLive.IssuesMachine

  test "reload contexts for view" do
    context = Repo.insert! %Context {
      title: "Task",
      view: "Software"
    }
    state = %{
      selected_view: "Software"
    }
    new_state = IssuesMachine.init_context_properties state

    assert List.first(new_state.contexts).id == context.id
    assert new_state.selected_context == nil
    assert new_state.selected_view == "Software"
  end

  test "delete context and leave issue in other context" do
    context = Repo.insert! %Context {
      title: "Project",
      view: "Software"
    }
    other_context = Repo.insert! %Context {
      title: "Component",
      view: "Software"
    }
    Repo.insert! %Issue {
      title: "Issue",
      contexts: [%{ context: context },
                 %{ context: other_context }]
    }
    state = %{
      q: "",
      selected_view: "Software",
      sort_issues_alphabetically: 0,
      list_issues_done_instead_open: false # TODO why do I need this?
    }
    assert 2 == length Tracker.list_contexts "Software"
    IssuesMachine.delete_context state, context.id
    assert 1 == length Tracker.list_contexts "Software"

    issues = (List.first Tracker.list_contexts "Software").issues
    assert 1 == length issues
  end

  test "delete context and remove issue from tag context" do
    context = Repo.insert! %Context {
      title: "Project",
      view: "Software"
    }
    tag_context = Repo.insert! %Context {
      title: "Task",
      view: "Software",
      is_tag?: true
    }
    Repo.insert! %Issue {
      title: "Issue",
      contexts: [%{ context: context },
                 %{ context: tag_context }]
    }
    state = %{
      q: "",
      selected_view: "Software",
      sort_issues_alphabetically: 0,
      list_issues_done_instead_open: false
    }
    IssuesMachine.delete_context state, context.id

    issues = (List.first Tracker.list_contexts "Software").issues
    assert 0 == length issues
  end

  test "delete tag_context" do
    tag_context = Repo.insert! %Context {
      title: "Task",
      view: "Software",
      is_tag?: true,
      important: true
    }
    Repo.insert! %Issue {
      title: "Issue",
      contexts: [%{ context: tag_context }]
    }
    state = %{
      q: "",
      selected_view: "Software",
      sort_issues_alphabetically: 0,
      list_issues_done_instead_open: false
    }

    assert 1 = length Tracker.list_issues %Tracker.Query {
      q: "",
      list_issues_done_instead_open: false,
      selected_view: "Software"
    }
    IssuesMachine.delete_context state, tag_context.id
    assert 0 = length Tracker.list_issues %Tracker.Query {
      q: "",
      list_issues_done_instead_open: false,
      selected_view: "Software"
    }
  end

  test "delete tag_context and leave issue in other context" do
    context = Repo.insert! %Context {
      title: "Project",
      view: "Software"
    }
    tag_context = Repo.insert! %Context {
      title: "Task",
      view: "Software",
      is_tag?: true
    }
    Repo.insert! %Issue {
      title: "Issue",
      contexts: [%{ context: context },
                 %{ context: tag_context }]
    }
    state = %{
      q: "",
      selected_view: "Software",
      sort_issues_alphabetically: 0,
      list_issues_done_instead_open: false
    }
    IssuesMachine.delete_context state, tag_context.id
    assert 1 == length (List.first Tracker.list_contexts "Software").issues
  end

  test "delete tag_context and remove issue also from other tag_context" do
    tag_context = Repo.insert! %Context {
      title: "Task1",
      view: "Software",
      is_tag?: true,
      important: true
    }
    other_tag_context = Repo.insert! %Context {
      title: "Task2",
      view: "Software",
      is_tag?: true,
      important: true
    }
    Repo.insert! %Issue {
      title: "Issue",
      contexts: [%{ context: tag_context },
                 %{ context: other_tag_context }]
    }
    state = %{
      q: "",
      selected_view: "Software",
      sort_issues_alphabetically: 0,
      list_issues_done_instead_open: false
    }
    assert 1 == length Tracker.list_issues %Tracker.Query {
      q: "",
      list_issues_done_instead_open: false,
      selected_view: "Software"
    }
    IssuesMachine.delete_context state, tag_context.id
    assert 0 == length Tracker.list_issues %Tracker.Query {
      list_issues_done_instead_open: false,
      selected_view: "Software"
    }
  end

  test "delete tag_context when there is also another tag_context, but leave issue in yet another context" do
    context = Repo.insert! %Context {
      title: "Project",
      view: "Software",
      important: true
    }
    tag_context = Repo.insert! %Context {
      title: "Task1",
      view: "Software",
      is_tag?: true,
      important: true
    }
    other_tag_context = Repo.insert! %Context {
      title: "Task2",
      view: "Software",
      is_tag?: true,
      important: true
    }
    Repo.insert! %Issue {
      title: "Issue",
      contexts: [%{ context: context },
                 %{ context: tag_context },
                 %{ context: other_tag_context }]
    }
    state = %{
      q: "",
      selected_view: "Software",
      sort_issues_alphabetically: 0,
      list_issues_done_instead_open: false
    }

    assert 3 == length (List.first Tracker.list_issues %Tracker.Query {
      list_issues_done_instead_open: false,
      selected_view: "Software"
    }).contexts
    IssuesMachine.delete_context state, tag_context.id
    assert 2 == length (List.first Tracker.list_issues %Tracker.Query {
        list_issues_done_instead_open: false,
        selected_view: "Software"
      }).contexts
  end

  test "previous context" do
    ctx1 = Repo.insert! %Context {
      title: "Project1",
      view: "Software"
    }
    ctx2 = Repo.insert! %Context {
      title: "Project2",
      view: "Software"
    }
    state = %{
      q: "",
      selected_view: "Software",
      selected_issue: nil,
      sort_issues_alphabetically: 0,
      list_issues_done_instead_open: false
    }
    state =
      state
      |> IssuesMachine.init_context_properties
      |> IssuesMachine.select_context(ctx1.id)
      |> IssuesMachine.select_context(ctx2.id)
      |> IssuesMachine.select_previous_context
    assert "Project1" == state.selected_context.title

    state =
      state
      |> IssuesMachine.init_context_properties
      |> IssuesMachine.select_context(ctx2.id)
      |> IssuesMachine.select_context(ctx1.id)
      |> IssuesMachine.select_previous_context
    assert "Project2" == state.selected_context.title
  end
end
