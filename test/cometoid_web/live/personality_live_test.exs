defmodule CometoidWeb.PersonalityLiveTest do
  use CometoidWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Cometoid.Writing

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp fixture(:personality) do
    {:ok, personality} = Writing.create_personality(@create_attrs)
    personality
  end

  defp create_personality(_) do
    personality = fixture(:personality)
    %{personality: personality}
  end

  describe "Index" do
    setup [:create_personality]

    test "lists all personalities", %{conn: conn, personality: personality} do
      {:ok, _index_live, html} = live(conn, Routes.personality_index_path(conn, :index))

      assert html =~ "Listing Personalities"
      assert html =~ personality.name
    end

    test "saves new personality", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.personality_index_path(conn, :index))

      assert index_live |> element("a", "New Personality") |> render_click() =~
               "New Personality"

      assert_patch(index_live, Routes.personality_index_path(conn, :new))

      assert index_live
             |> form("#personality-form", personality: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#personality-form", personality: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.personality_index_path(conn, :index))

      assert html =~ "Personality created successfully"
      assert html =~ "some name"
    end

    test "updates personality in listing", %{conn: conn, personality: personality} do
      {:ok, index_live, _html} = live(conn, Routes.personality_index_path(conn, :index))

      assert index_live |> element("#personality-#{personality.id} a", "Edit") |> render_click() =~
               "Edit Personality"

      assert_patch(index_live, Routes.personality_index_path(conn, :edit, personality))

      assert index_live
             |> form("#personality-form", personality: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#personality-form", personality: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.personality_index_path(conn, :index))

      assert html =~ "Personality updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes personality in listing", %{conn: conn, personality: personality} do
      {:ok, index_live, _html} = live(conn, Routes.personality_index_path(conn, :index))

      assert index_live |> element("#personality-#{personality.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#personality-#{personality.id}")
    end
  end

  describe "Show" do
    setup [:create_personality]

    test "displays personality", %{conn: conn, personality: personality} do
      {:ok, _show_live, html} = live(conn, Routes.personality_show_path(conn, :show, personality))

      assert html =~ "Show Personality"
      assert html =~ personality.name
    end

    test "updates personality within modal", %{conn: conn, personality: personality} do
      {:ok, show_live, _html} = live(conn, Routes.personality_show_path(conn, :show, personality))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Personality"

      assert_patch(show_live, Routes.personality_show_path(conn, :edit, personality))

      assert show_live
             |> form("#personality-form", personality: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#personality-form", personality: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.personality_show_path(conn, :show, personality))

      assert html =~ "Personality updated successfully"
      assert html =~ "some updated name"
    end
  end
end
