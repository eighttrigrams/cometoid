defmodule CometoidWeb.DateFormHelpers do

  def init_params existing do
    params = %{
      "has_event?" => (if existing do "true" else "false" end),
      "event" => %{
        "archived" => "false",
        "date" => (if existing do to_date_map(existing) else local_time() end)
      }
    }
    day_options = get_day_options params["event"]["date"] # TODO add version which takes params
    {params, day_options}
  end

  def clean_event params do
    if has_event? params do
      params
    else
      Map.delete params, "event"
    end
  end

  def adjust_date %{ "event" => %{ "date" => %{ "day" => day } = date }} = params do
    day_options = get_day_options(date)
    {day_i, ""} = Integer.parse day
    day = unless day_i in day_options do
      Integer.to_string List.last Enum.to_list day_options
    else
      day
    end
    params = put_in params["event"]["date"]["day"], day
    {params, day_options}
  end

  def update_params %{ "has_event?" => has_event? } = params, previous_params do
    params = Map.put params, "has_event?", has_event?
    Map.put params, "event", previous_params["event"]
  end

  def date_tuple_from %{ "event" => %{ "date" => %{ "year" => year, "month" => month, "day" => day }}} do
    { year, month, day }
  end

  defp to_date_map date_sigil do
    %{
      "year" => Integer.to_string(date_sigil.year),
      "month" => Integer.to_string(date_sigil.month),
      "day" => Integer.to_string(date_sigil.day)
    }
  end

  defp to_sigil %{ "year" => year, "month" => month, "day" => day } do
    date = year
    month = if String.length(month) == 1 do "0" <> month else month end
    Date.from_iso8601! year <> "-" <> month <> "-" <> "01"
  end

  defp local_time do
    {{year, month, day}, _} = :calendar.local_time()
    day = Integer.to_string(day)
    month = Integer.to_string(month)
    year = Integer.to_string(year)
    %{"day" => day, "month" => month, "year" => year }
  end

  defp get_day_options %{ "year" => _year } = date do
    date = to_sigil date
    1..Date.days_in_month date
  end

  defp get_day_options date do
    1..Date.days_in_month date
  end

  defp has_event? %{ "has_event?" => has_event? } do
    has_event? == "true"
  end
end
