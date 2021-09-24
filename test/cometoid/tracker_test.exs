defmodule Cometoid.TrackerTest do
  use Cometoid.DataCase

  alias Cometoid.Tracker

  describe "issues" do

    @valid_attrs %{description: "some description", done: true, title: "some title"}
    # @update_attrs %{description: "some updated description", done: false, title: "some updated title"}
    # @invalid_attrs %{description: nil, done: nil, title: nil}

    def issue_fixture() do
      # {:ok, issue} =
      # attsrs
      # |> Enum.into(@valid_attrs)
      # |> Tracker.create_issue()

      Tracker.create_issue_type(%{ title: "issue-type-1"})
      {:ok, context} = Tracker.create_context(%{ title: "context-1"})
      {:ok, issue} = Tracker.create_issue("issue-1", %{ title: "context-1" }, %{ title: "issue-type-1" })
      [context, issue]
    end


    test "list_issues/1 returns all issues" do
      [context, issue] = issue_fixture()
      query = %{
        selected_issue_type: nil,
        selected_context: context,
        list_issues_done_instead_open: false
      }
      assert Tracker.list_issues(query) == [issue]
    end

    test "get_issue!/1 returns the issue with given id" do
      [_, issue] = issue_fixture()
      assert Tracker.get_issue!(issue.id) == issue
    end



    # test "create_issue/1 with valid data creates a issue" do
      # assert {:ok, %issue{} = issue} = Tracker.create_issue(@valid_attrs)
      # assert issue.description == "some description"
      # assert issue.done == true
      # assert issue.title == "some title"
      # assert issue.type == "some type"
    # end
#
    # test "create_issue/1 with invalid data returns error changeset" do
      # assert {:error, %Ecto.Changeset{}} = Tracker.create_issue(@invalid_attrs)
    # end
#
    # test "update_issue/2 with valid data updates the issue" do
      # issue = issue_fixture()
      # assert {:ok, %issue{} = issue} = Tracker.update_issue(issue, @update_attrs)
      # assert issue.description == "some updated description"
      # assert issue.done == false
      # assert issue.title == "some updated title"
      # assert issue.type == "some updated type"
    # end
#
    # test "update_issue/2 with invalid data returns error changeset" do
      # issue = issue_fixture()
      # assert {:error, %Ecto.Changeset{}} = Tracker.update_issue(issue, @invalid_attrs)
      # assert issue == Tracker.get_issue!(issue.id)
    # end
#
    # test "delete_issue/1 deletes the issue" do
      # issue = issue_fixture()
      # assert {:ok, %issue{}} = Tracker.delete_issue(issue)
      # assert_raise Ecto.NoResultsError, fn -> Tracker.get_issue!(issue.id) end
    # end
#
    # test "change_issue/1 returns a issue changeset" do
      # issue = issue_fixture()
      # assert %Ecto.Changeset{} = Tracker.change_issue(issue)
    # end
  end

  describe "contexts" do
    @valid_attrs %{title: "some title"}
    # @update_attrs %{title: "some updated title"}
    # @invalid_attrs %{title: nil}

    def context_fixture(attrs \\ %{}) do
      {:ok, context} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Tracker.create_context()

      context
    end

    test "list_contexts/0 returns all contexts" do
      context = context_fixture()
      assert List.first(Tracker.list_contexts()).title == context.title
    end

    # test "get_context!/1 returns the context with given id" do
      # context = context_fixture()
      # assert Contexts.get_context!(context.id) == context
    # end
#
    # test "create_context/1 with valid data creates a context" do
      # assert {:ok, %Context{} = context} = Contexts.create_context(@valid_attrs)
      # assert context.title == "some title"
    # end
#
    # test "create_context/1 with invalid data returns error changeset" do
      # assert {:error, %Ecto.Changeset{}} = Contexts.create_context(@invalid_attrs)
    # end
#
    # test "update_context/2 with valid data updates the context" do
      # context = context_fixture()
      # assert {:ok, %Context{} = context} = Contexts.update_context(context, @update_attrs)
      # assert context.title == "some updated title"
    # end
#
    # test "update_context/2 with invalid data returns error changeset" do
      # context = context_fixture()
      # assert {:error, %Ecto.Changeset{}} = Contexts.update_context(context, @invalid_attrs)
      # assert context == Contexts.get_context!(context.id)
    # end
#
    # test "delete_context/1 deletes the context" do
      # context = context_fixture()
      # assert {:ok, %Context{}} = Contexts.delete_context(context)
      # assert_raise Ecto.NoResultsError, fn -> Contexts.get_context!(context.id) end
    # end
#
    # test "change_context/1 returns a context changeset" do
      # context = context_fixture()
      # assert %Ecto.Changeset{} = Contexts.change_context(context)
    # end
  end

  # describe "issue_types" do
    # alias Cometoid.Contexts.IssueType
#
    # @valid_attrs %{title: "some title"}
    # @update_attrs %{title: "some updated title"}
    # @invalid_attrs %{title: nil}
#
    # def issue_type_fixture(attrs \\ %{}) do
      # {:ok, issue_type} =
        # attrs
        # |> Enum.into(@valid_attrs)
        # |> Contexts.create_issue_type()
#
      # issue_type
    # end
#
    # test "list_issue_types/0 returns all issue_types" do
      # issue_type = issue_type_fixture()
      # assert Contexts.list_issue_types() == [issue_type]
    # end
#
    # test "get_issue_type!/1 returns the issue_type with given id" do
      # issue_type = issue_type_fixture()
      # assert Contexts.get_issue_type!(issue_type.id) == issue_type
    # end
#
    # test "create_issue_type/1 with valid data creates a issue_type" do
      # assert {:ok, %IssueType{} = issue_type} = Contexts.create_issue_type(@valid_attrs)
      # assert issue_type.title == "some title"
    # end
#
    # test "create_issue_type/1 with invalid data returns error changeset" do
      # assert {:error, %Ecto.Changeset{}} = Contexts.create_issue_type(@invalid_attrs)
    # end
#
    # test "update_issue_type/2 with valid data updates the issue_type" do
      # issue_type = issue_type_fixture()
      # assert {:ok, %IssueType{} = issue_type} = Contexts.update_issue_type(issue_type, @update_attrs)
      # assert issue_type.title == "some updated title"
    # end
#
    # test "update_issue_type/2 with invalid data returns error changeset" do
      # issue_type = issue_type_fixture()
      # assert {:error, %Ecto.Changeset{}} = Contexts.update_issue_type(issue_type, @invalid_attrs)
      # assert issue_type == Contexts.get_issue_type!(issue_type.id)
    # end
#
    # test "delete_issue_type/1 deletes the issue_type" do
      # issue_type = issue_type_fixture()
      # assert {:ok, %IssueType{}} = Contexts.delete_issue_type(issue_type)
      # assert_raise Ecto.NoResultsError, fn -> Contexts.get_issue_type!(issue_type.id) end
    # end
#
    # test "change_issue_type/1 returns a issue_type changeset" do
      # issue_type = issue_type_fixture()
      # assert %Ecto.Changeset{} = Contexts.change_issue_type(issue_type)
    # end
  # end
#
  # describe "context_types" do
    # alias Cometoid.Contexts.ContextType
#
    # @valid_attrs %{title: "some title"}
    # @update_attrs %{title: "some updated title"}
    # @invalid_attrs %{title: nil}
#
    # def context_type_fixture(attrs \\ %{}) do
      # {:ok, context_type} =
        # attrs
        # |> Enum.into(@valid_attrs)
        # |> Contexts.create_context_type()
#
      # context_type
    # end
#
    # test "list_context_types/0 returns all context_types" do
      # context_type = context_type_fixture()
      # assert Contexts.list_context_types() == [context_type]
    # end
#
    # test "get_context_type!/1 returns the context_type with given id" do
      # context_type = context_type_fixture()
      # assert Contexts.get_context_type!(context_type.id) == context_type
    # end
#
    # test "create_context_type/1 with valid data creates a context_type" do
      # assert {:ok, %ContextType{} = context_type} = Contexts.create_context_type(@valid_attrs)
      # assert context_type.title == "some title"
    # end
#
    # test "create_context_type/1 with invalid data returns error changeset" do
      # assert {:error, %Ecto.Changeset{}} = Contexts.create_context_type(@invalid_attrs)
    # end
#
    # test "update_context_type/2 with valid data updates the context_type" do
      # context_type = context_type_fixture()
      # assert {:ok, %ContextType{} = context_type} = Contexts.update_context_type(context_type, @update_attrs)
      # assert context_type.title == "some updated title"
    # end
#
    # test "update_context_type/2 with invalid data returns error changeset" do
      # context_type = context_type_fixture()
      # assert {:error, %Ecto.Changeset{}} = Contexts.update_context_type(context_type, @invalid_attrs)
      # assert context_type == Contexts.get_context_type!(context_type.id)
    # end
#
    # test "delete_context_type/1 deletes the context_type" do
      # context_type = context_type_fixture()
      # assert {:ok, %ContextType{}} = Contexts.delete_context_type(context_type)
      # assert_raise Ecto.NoResultsError, fn -> Contexts.get_context_type!(context_type.id) end
    # end
#
    # test "change_context_type/1 returns a context_type changeset" do
      # context_type = context_type_fixture()
      # assert %Ecto.Changeset{} = Contexts.change_context_type(context_type)
    # end
  # end
end
