defmodule Cometoid.Indexer do

  alias Cometoid.Repo.Writing
  alias Cometoid.IndexAdapter

  defp convert %{ content: content, reading_title: reading_title, id: id, page_nr: page_nr, alt_page_nr: alt_page_nr } do
    %{ content: content, reading_title: reading_title, id: id, page_nr: page_nr, alt_page_nr: alt_page_nr }
  end

  defp convert_reading reading do
    Enum.map(reading.quotes, &(Map.merge(&1, %{ reading_title: reading.title })))
  end

  defp index_quote _quote = %{ id: id } do
    IndexAdapter.index_one "quote-" <> to_string(id), _quote
  end

  def index_quotes do
    Writing.list_readings()
    |> Enum.flat_map(&convert_reading/1)
    |> Enum.map(&convert/1)
    |> Enum.map(&index_quote/1)
  end
end
