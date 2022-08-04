defmodule Cometoid.Tracker.SearchTest do
  use Cometoid.RepoCase

  alias Cometoid.Repo.Tracker
  alias Cometoid.Repo.Tracker.Search

  describe "search" do

    test "prefix search issues" do
      {:ok, c1} = Tracker.create_context %{ "title" => "context1", "view" => "view1" }    
      Tracker.create_issue "abc", "short title 1", [c1]
      Tracker.create_issue "abd", "short title 2", [c1]
      Tracker.create_issue "acd", "short title 2", [c1]

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
