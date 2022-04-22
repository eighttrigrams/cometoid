defmodule CometoidWeb.DateHelpers do

  def init_params existing do
    %{
      "has_event?" => (if existing do "true" else "false" end),
      "event" => %{
        "archived" => "false",
        "date" => (if existing do to_date_map(existing) else local_time() end)
      }
    }
  end

  def to_date_map date_sigil do
    %{
      "year" => Integer.to_string(date_sigil.year),
      "month" => Integer.to_string(date_sigil.month),
      "day" => Integer.to_string(date_sigil.day)
    }
  end

  def to_sigil %{ "year" => year, "month" => month, "day" => day } do
    date = year
    month = if String.length(month) == 1 do "0" <> month else month end
    Date.from_iso8601! year <> "-" <> month <> "-" <> "01"
  end

  def local_time do
    {{year, month, day}, _} = :calendar.local_time()
    day = Integer.to_string(day)
    month = Integer.to_string(month)
    year = Integer.to_string(year)
    %{"day" => day, "month" => month, "year" => year }
  end

  def date_tuple_from %{ "event" => %{ "date" => %{ "year" => year, "month" => month, "day" => day }}} do
    { year, month, day }
  end

  def get_day_options %{ "year" => _year } = date do
    date = to_sigil date
    1..Date.days_in_month date
  end

  def get_day_options date do
    1..Date.days_in_month date
  end

  def has_event? %{ "has_event?" => has_event? } do
    has_event? == "true"
  end
end
