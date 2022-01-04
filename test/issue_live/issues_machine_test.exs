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
    new_state = IssuesMachine.set_context_properties state

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
      selected_view: "Software",
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
      selected_view: "Software",
      list_issues_done_instead_open: false
    }
    assert 2 == length Tracker.list_contexts "Software"
    IssuesMachine.delete_context state, context.id
    assert 1 == length Tracker.list_contexts "Software"

    issues = (List.first Tracker.list_contexts "Software").issues
    assert 0 == length issues
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
      selected_view: "Software",
      list_issues_done_instead_open: false
    }
    assert 2 == length Tracker.list_contexts "Software"
    IssuesMachine.delete_context state, tag_context.id
    assert 1 == length Tracker.list_contexts "Software"

    issues = (List.first Tracker.list_contexts "Software").issues
    assert 1 == length issues
  end
end
