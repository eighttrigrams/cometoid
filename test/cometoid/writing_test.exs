defmodule Cometoid.WritingTest do
  use Cometoid.DataCase

  alias Cometoid.Writing

  describe "texts" do
    alias Cometoid.Writing.Text

    @valid_attrs %{audience: "some audience", description: "some description", title: "some title", type: "some type"}
    @update_attrs %{audience: "some updated audience", description: "some updated description", title: "some updated title", type: "some updated type"}
    @invalid_attrs %{audience: nil, description: nil, title: nil, type: nil}

    def text_fixture(attrs \\ %{}) do
      {:ok, text} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Writing.create_text()

      text
    end

    test "list_texts/0 returns all texts" do
      text = text_fixture()
      assert Writing.list_texts() == [text]
    end

    test "get_text!/1 returns the text with given id" do
      text = text_fixture()
      assert Writing.get_text!(text.id) == text
    end

    test "create_text/1 with valid data creates a text" do
      assert {:ok, %Text{} = text} = Writing.create_text(@valid_attrs)
      assert text.audience == "some audience"
      assert text.description == "some description"
      assert text.title == "some title"
      assert text.type == "some type"
    end

    test "create_text/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Writing.create_text(@invalid_attrs)
    end

    test "update_text/2 with valid data updates the text" do
      text = text_fixture()
      assert {:ok, %Text{} = text} = Writing.update_text(text, @update_attrs)
      assert text.audience == "some updated audience"
      assert text.description == "some updated description"
      assert text.title == "some updated title"
      assert text.type == "some updated type"
    end

    test "update_text/2 with invalid data returns error changeset" do
      text = text_fixture()
      assert {:error, %Ecto.Changeset{}} = Writing.update_text(text, @invalid_attrs)
      assert text == Writing.get_text!(text.id)
    end

    test "delete_text/1 deletes the text" do
      text = text_fixture()
      assert {:ok, %Text{}} = Writing.delete_text(text)
      assert_raise Ecto.NoResultsError, fn -> Writing.get_text!(text.id) end
    end

    test "change_text/1 returns a text changeset" do
      text = text_fixture()
      assert %Ecto.Changeset{} = Writing.change_text(text)
    end
  end

  describe "readings" do
    alias Cometoid.Writing.Reading

    @valid_attrs %{author: "some author", description: "some description", publication_info: "some publication_info", title: "some title"}
    @update_attrs %{author: "some updated author", description: "some updated description", publication_info: "some updated publication_info", title: "some updated title"}
    @invalid_attrs %{author: nil, description: nil, publication_info: nil, title: nil}

    def reading_fixture(attrs \\ %{}) do
      {:ok, reading} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Writing.create_reading()

      reading
    end

    test "list_readings/0 returns all readings" do
      reading = reading_fixture()
      assert Writing.list_readings() == [reading]
    end

    test "get_reading!/1 returns the reading with given id" do
      reading = reading_fixture()
      assert Writing.get_reading!(reading.id) == reading
    end

    test "create_reading/1 with valid data creates a reading" do
      assert {:ok, %Reading{} = reading} = Writing.create_reading(@valid_attrs)
      assert reading.author == "some author"
      assert reading.description == "some description"
      assert reading.publication_info == "some publication_info"
      assert reading.title == "some title"
    end

    test "create_reading/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Writing.create_reading(@invalid_attrs)
    end

    test "update_reading/2 with valid data updates the reading" do
      reading = reading_fixture()
      assert {:ok, %Reading{} = reading} = Writing.update_reading(reading, @update_attrs)
      assert reading.author == "some updated author"
      assert reading.description == "some updated description"
      assert reading.publication_info == "some updated publication_info"
      assert reading.title == "some updated title"
    end

    test "update_reading/2 with invalid data returns error changeset" do
      reading = reading_fixture()
      assert {:error, %Ecto.Changeset{}} = Writing.update_reading(reading, @invalid_attrs)
      assert reading == Writing.get_reading!(reading.id)
    end

    test "delete_reading/1 deletes the reading" do
      reading = reading_fixture()
      assert {:ok, %Reading{}} = Writing.delete_reading(reading)
      assert_raise Ecto.NoResultsError, fn -> Writing.get_reading!(reading.id) end
    end

    test "change_reading/1 returns a reading changeset" do
      reading = reading_fixture()
      assert %Ecto.Changeset{} = Writing.change_reading(reading)
    end
  end

  describe "quotes" do
    alias Cometoid.Writing.Quote

    @valid_attrs %{content: "some content"}
    @update_attrs %{content: "some updated content"}
    @invalid_attrs %{content: nil}

    def quote_fixture(attrs \\ %{}) do
      {:ok, quote} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Writing.create_quote()

      quote
    end

    test "list_quotes/0 returns all quotes" do
      quote = quote_fixture()
      assert Writing.list_quotes() == [quote]
    end

    test "get_quote!/1 returns the quote with given id" do
      quote = quote_fixture()
      assert Writing.get_quote!(quote.id) == quote
    end

    test "create_quote/1 with valid data creates a quote" do
      assert {:ok, %Quote{} = quote} = Writing.create_quote(@valid_attrs)
      assert quote.content == "some content"
    end

    test "create_quote/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Writing.create_quote(@invalid_attrs)
    end

    test "update_quote/2 with valid data updates the quote" do
      quote = quote_fixture()
      assert {:ok, %Quote{} = quote} = Writing.update_quote(quote, @update_attrs)
      assert quote.content == "some updated content"
    end

    test "update_quote/2 with invalid data returns error changeset" do
      quote = quote_fixture()
      assert {:error, %Ecto.Changeset{}} = Writing.update_quote(quote, @invalid_attrs)
      assert quote == Writing.get_quote!(quote.id)
    end

    test "delete_quote/1 deletes the quote" do
      quote = quote_fixture()
      assert {:ok, %Quote{}} = Writing.delete_quote(quote)
      assert_raise Ecto.NoResultsError, fn -> Writing.get_quote!(quote.id) end
    end

    test "change_quote/1 returns a quote changeset" do
      quote = quote_fixture()
      assert %Ecto.Changeset{} = Writing.change_quote(quote)
    end
  end

  describe "personalities" do
    alias Cometoid.Writing.Personality

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def personality_fixture(attrs \\ %{}) do
      {:ok, personality} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Writing.create_personality()

      personality
    end

    test "list_personalities/0 returns all personalities" do
      personality = personality_fixture()
      assert Writing.list_personalities() == [personality]
    end

    test "get_personality!/1 returns the personality with given id" do
      personality = personality_fixture()
      assert Writing.get_personality!(personality.id) == personality
    end

    test "create_personality/1 with valid data creates a personality" do
      assert {:ok, %Personality{} = personality} = Writing.create_personality(@valid_attrs)
      assert personality.name == "some name"
    end

    test "create_personality/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Writing.create_personality(@invalid_attrs)
    end

    test "update_personality/2 with valid data updates the personality" do
      personality = personality_fixture()
      assert {:ok, %Personality{} = personality} = Writing.update_personality(personality, @update_attrs)
      assert personality.name == "some updated name"
    end

    test "update_personality/2 with invalid data returns error changeset" do
      personality = personality_fixture()
      assert {:error, %Ecto.Changeset{}} = Writing.update_personality(personality, @invalid_attrs)
      assert personality == Writing.get_personality!(personality.id)
    end

    test "delete_personality/1 deletes the personality" do
      personality = personality_fixture()
      assert {:ok, %Personality{}} = Writing.delete_personality(personality)
      assert_raise Ecto.NoResultsError, fn -> Writing.get_personality!(personality.id) end
    end

    test "change_personality/1 returns a personality changeset" do
      personality = personality_fixture()
      assert %Ecto.Changeset{} = Writing.change_personality(personality)
    end
  end
end
