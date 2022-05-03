defmodule Cometoid.TrackerTest do
  use Cometoid.RepoCase

  alias Cometoid.Model.Tracker.Issue
  alias Cometoid.Repo.Tracker

  test "link issues" do
    {:ok, i1} = Tracker.create_issue "full title 1", "short title 1", []
    {:ok, i2} = Tracker.create_issue "full title 2", "short title 2", []

    i1 = Tracker.get_issue! i1.id # TODO review, remove this line
    {:ok, i1} = Tracker.link_issues i1, [i2.id]
    i2 = Tracker.get_issue! i2.id
    assert List.first(i1.issues).id == i2.id
    assert List.first(i2.issues).id == i1.id
  end
end
