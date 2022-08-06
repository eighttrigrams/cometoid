defmodule CometoidWeb.IssueLive.IssuesMachineTest do
  use Cometoid.RepoCase

  alias Cometoid.Repo.Tracker
  alias Cometoid.Repo.Tracker.Search
  alias Cometoid.Model.Tracker.Context
  alias Cometoid.Model.Tracker.Issue
  alias Cometoid.State.IssuesMachine

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

  describe "deletion" do

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
      state = IssuesMachine.State.new "Software"
      assert 2 == length Search.list_contexts "Software"
      IssuesMachine.delete_context state, context.id
      assert 1 == length Search.list_contexts "Software"

      issues = (List.first Search.list_contexts "Software").issues
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
        search: %{
          q: "",
          show_all_issues: false
        },
        selected_view: "Software",
        sort_issues_alphabetically: 0,
        list_issues_done_instead_open: false
      }
      IssuesMachine.delete_context state, context.id

      issues = (List.first Search.list_contexts "Software").issues
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
      state = IssuesMachine.State.new "Software"
      assert 1 = length Search.list_issues state
      IssuesMachine.delete_context state, tag_context.id
      assert 0 = length Search.list_issues state
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
        search: %{
          show_all_issues: false,
          q: ""
        },
        selected_view: "Software",
        sort_issues_alphabetically: 0,
        list_issues_done_instead_open: false
      }
      IssuesMachine.delete_context state, tag_context.id
      assert 1 == length (List.first Search.list_contexts "Software").issues
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
      state = IssuesMachine.State.new "Software"
      assert 1 == length Search.list_issues state
      IssuesMachine.delete_context state, tag_context.id
      assert 0 == length Search.list_issues state
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
      state = IssuesMachine.State.new "Software"
      assert 3 == length (List.first Search.list_issues state).contexts
      IssuesMachine.delete_context state, tag_context.id
      assert 2 == length (List.first Search.list_issues state).contexts
    end

    test "delete context with issues connected to other issues" do
      context = Repo.insert! %Context {
        title: "Project",
        view: "Software",
        important: true
      }
      issue1 = Tracker.create_issue! "Issue1", "", [context]
      issue2 = Tracker.create_issue! "Issue2", "", [context]
      Tracker.link_issues issue1, [issue2.id]
      state = IssuesMachine.State.new "Software"
      assert 2 == length Search.list_issues state
      IssuesMachine.delete_context state, context.id
      assert 0 == length Search.list_issues state
    end
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
      qsearch: %{
        show_all_issues: false,
        q: ""
      },
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

  ## ISSUES SHOWN IN ISSUES LIST

  test "important issues shown when not in issue search search" do
    important_context = Repo.insert! %Context {
      title: "Important Context",
      view: "Software",
      important: true
    }
    context_with_important_issue = Repo.insert! %Context {
      title: "Important Context",
      view: "Software"
    }
    context = Repo.insert! %Context {
      title: "Context",
      view: "Software",
      important: false
    }
    Repo.insert! %Issue {
      title: "Issue 1",
      contexts: [%{ context: important_context }]
    }
    Repo.insert! %Issue {
      title: "Issue 2",
      important: true,
      contexts: [%{ context: context_with_important_issue }]
    }
    Repo.insert! %Issue {
      title: "Issue 3",
      contexts: [%{ context: context_with_important_issue }]
    }
    Repo.insert! %Issue {
      title: "Issue 4",
      contexts: [%{ context: context }]
    }
    state = %{
      search: %{
        show_all_issues: false,
        q: ""
      },
      selected_context: nil,
      selected_issue: nil,
      selected_view: "Software",
      sort_issues_alphabetically: 0,
      list_issues_done_instead_open: false
    }
    state = IssuesMachine.refresh_issues state

    assert (MapSet.new ["Issue 1", "Issue 2"]) 
      == MapSet.new Enum.map state.issues, &(&1.title)
  end
end
