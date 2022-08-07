defmodule Cometoid.Tracker.SearchTest do
  use Cometoid.RepoCase

  alias Cometoid.Repo.Tracker
  alias Cometoid.Repo.Tracker.Search
  alias Cometoid.State.IssuesMachine

  def titles_set_from issues do
    MapSet.new Enum.map issues, &(&1.title)
  end

  test "filter for secondary contexts" do
    {:ok, c1} = Tracker.create_context %{ "title" => "context1", "view" => "view1" }    
    {:ok, c2} = Tracker.create_context %{ "title" => "context2", "view" => "view1" }    
    Tracker.create_issue "1", "short title 1", [c1]
    Tracker.create_issue "2", "short title 2", [c1, c2]
    Tracker.create_issue "3", "short title 3", [c2]

    state = (IssuesMachine.State.new "view1")
      |> put_in([:selected_context], c1)
      |> put_in([:selected_secondary_contexts], [c1.id, c2.id])
    issues = titles_set_from Search.list_issues state
    assert (MapSet.new ["2"]) == issues
  end

  describe "fulltext" do

    test "prefix search issues" do
      {:ok, c1} = Tracker.create_context %{ "title" => "context1", "view" => "view1" }    
      Tracker.create_issue "abc", "short title 1", [c1]
      Tracker.create_issue "abd", "short title 2", [c1]
      Tracker.create_issue "acd", "short title 2", [c1]

      state = (IssuesMachine.State.new "view1")
        |> put_in([:search, :q], "ab")
      
      issues = titles_set_from Search.list_issues state
      assert (MapSet.new ["abc", "abd"]) == issues
    end 

    test "prefix search issues on short_title, too" do
      {:ok, c1} = Tracker.create_context %{ "title" => "context1", "view" => "view1" }    
      Tracker.create_issue "abc", "short title 1", [c1]
      Tracker.create_issue "aaa", "abd", [c1]
      Tracker.create_issue "acd", "ace", [c1]

      state = (IssuesMachine.State.new "view1")
        |> put_in([:search, :q], "ab")

      issues = titles_set_from Search.list_issues state
      assert (MapSet.new ["abc", "aaa"]) == issues
    end 

    test "multiple search terms (AND search)" do
      {:ok, c1} = Tracker.create_context %{ "title" => "context1", "view" => "view1" }    
      Tracker.create_issue "abc aaa", "", [c1]
      Tracker.create_issue "aaa", "", [c1]
      Tracker.create_issue "ccc", "", [c1]

      state = (IssuesMachine.State.new "view1")
        |> put_in([:search, :q], "ab aa")

      issues = titles_set_from Search.list_issues state
      assert (MapSet.new ["abc aaa"]) == issues
    end
  end
end
