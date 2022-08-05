defmodule Cometoid.Tracker.SearchTest do
  use Cometoid.RepoCase

  alias Cometoid.Repo.Tracker
  alias Cometoid.Repo.Tracker.Search
  alias CometoidWeb.IssueLive.IssuesMachine # TODO <- should be in Cometoid, not CometoidWeb

  def titles_set_from issues do # TODO use throughout tests
    MapSet.new Enum.map issues, &(&1.title)
  end

  test "filter for secondary contexts" do
    {:ok, c1} = Tracker.create_context %{ "title" => "context1", "view" => "view1" }    
    {:ok, c2} = Tracker.create_context %{ "title" => "context2", "view" => "view1" }    
    Tracker.create_issue "1", "short title 1", [c1]
    Tracker.create_issue "2", "short title 2", [c1, c2]

    state = (IssuesMachine.State.new "view1")
      |> put_in([:selected_context], c1)
      |> put_in([:selected_secondary_contexts], [c2.id])
    issues = titles_set_from Search.list_issues state
    assert (MapSet.new ["2"]) == issues
  end

  describe "fulltext" do

    test "prefix search issues" do
      {:ok, c1} = Tracker.create_context %{ "title" => "context1", "view" => "view1" }    
      Tracker.create_issue "abc", "short title 1", [c1]
      Tracker.create_issue "abd", "short title 2", [c1]
      Tracker.create_issue "acd", "short title 2", [c1]

      # TODO use IssuesMachine.State
      query = %{
        selected_context: nil,
        list_issues_done_instead_open: false,
        sort_issues_alphabetically: false,
        selected_view: "view1",
        selected_issue: nil,
        search: %{
          q: "ab",
          show_all_issues: false
        }
      }

      issues = Search.list_issues query
      assert (MapSet.new ["abc", "abd"]) 
        == MapSet.new Enum.map issues, &(&1.title)
    end 

    test "prefix search issues on short_title, too" do
      {:ok, c1} = Tracker.create_context %{ "title" => "context1", "view" => "view1" }    
      Tracker.create_issue "abc", "short title 1", [c1]
      Tracker.create_issue "aaa", "abd", [c1]
      Tracker.create_issue "acd", "ace", [c1]

      query = %{
        selected_context: nil,
        list_issues_done_instead_open: false,
        sort_issues_alphabetically: false,
        selected_view: "view1",
        selected_issue: nil,
        search: %{
          q: "ab",
          show_all_issues: false
        }
      }

      issues = Search.list_issues query
      assert (MapSet.new ["abc", "aaa"]) 
        == MapSet.new Enum.map issues, &(&1.title)
    end 

    test "multiple search terms (AND search)" do
      {:ok, c1} = Tracker.create_context %{ "title" => "context1", "view" => "view1" }    
      Tracker.create_issue "abc aaa", "", [c1]
      Tracker.create_issue "aaa", "", [c1]
      Tracker.create_issue "ccc", "", [c1]

      query = %{
        selected_context: nil,
        list_issues_done_instead_open: false,
        sort_issues_alphabetically: false,
        selected_view: "view1",
        selected_issue: nil,
        search: %{
          q: "ab aa",
          show_all_issues: false
        }
      }

      issues = Search.list_issues query
      assert (MapSet.new ["abc aaa"]) 
        == MapSet.new Enum.map issues, &(&1.title)
    end
  end
end
