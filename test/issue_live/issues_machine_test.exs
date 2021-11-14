defmodule CometoidWeb.IssueLive.IssuesMachineTest do
  use Cometoid.RepoCase

  alias Cometoid.Model.Tracker.Context
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
end
