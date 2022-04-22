defmodule CometoidWeb.DateFormHelpers do

  def put_back_event params, previous_params, key do
    if not Map.has_key? params, key do
      Map.put params, key, previous_params[key]
    else
      params
    end
  end

  def adjust_date %{ "date" => %{ "day" => day }} = event do
    day_options = get_day_options event
    {day_i, ""} = Integer.parse day
    day = unless day_i in day_options do
      Integer.to_string List.last Enum.to_list day_options
    else
      day
    end
    event = put_in event["date"]["day"], day
    IO.inspect event
    {event, day_options}
  end

  def date_tuple_from %{ "date" => %{ "year" => year, "month" => month, "day" => day }} do
    { year, month, day }
  end

  def to_date_map date_sigil do
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

  def local_time do
    {{year, month, day}, _} = :calendar.local_time()
    day = Integer.to_string(day)
    month = Integer.to_string(month)
    year = Integer.to_string(year)
    %{"day" => day, "month" => month, "year" => year }
  end

  def get_day_options %{ "date" => date } do
    date = to_sigil date
    1..Date.days_in_month date
  end

  def get_day_options date do
    1..Date.days_in_month date
  end
end
