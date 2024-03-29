defmodule Cometoid.TrackerTest do
  use Cometoid.RepoCase

  alias Cometoid.Repo.Tracker

  test "link and unlink issues" do
    {:ok, i1} = Tracker.create_issue "full title 1", "short title 1", []
    {:ok, i2} = Tracker.create_issue "full title 2", "short title 2", []

    {:ok, i1} = Tracker.link_issues i1, [i2.id]
    i2 = Tracker.get_issue! i2.id
    assert List.first(i1.issues).id == i2.id
    assert List.first(i2.issues).id == i1.id

    {:ok, i1} = Tracker.link_issues i1, []
    i2 = Tracker.get_issue! i2.id
    assert i1.issues == []
    assert i2.issues == []
  end

  test "link and unlink contexts" do
    {:ok, c1} = Tracker.create_context %{ "title" => "context1", "view" => "view1" }
    {:ok, c2} = Tracker.create_context %{ "title" => "context2", "view" => "view2" }

    {:ok, c1} = Tracker.link_contexts c1, [c2.id]
    c2 = Tracker.get_context! c2.id
    assert List.first(c1.secondary_contexts).id == c2.id
    assert List.first(c2.secondary_contexts).id == c1.id

    {:ok, c1} = Tracker.link_contexts c1, []
    c2 = Tracker.get_context! c2.id
    assert c1.issues == []
    assert c2.issues == []
  end
end
