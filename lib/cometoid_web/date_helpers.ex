defmodule CometoidWeb.DateHelpers do

  def put_back_event params, previous_params, key do
    if not Map.has_key? params, key do
      Map.put params, key, previous_params[key]
    else
      params
    end
  end

  def adjust_date %{ "day" => day } = date do
    day_options = get_day_options date
    {day_i, ""} = Integer.parse day
    day = unless day_i in day_options do
      Integer.to_string List.last Enum.to_list day_options
    else
      day
    end
    {day, day_options}
  end

  def date_tuple_from %{ "year" => year, "month" => month, "day" => day } do
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

  def get_day_options %{ "year" => _year } = date do
    1..Date.days_in_month to_sigil date
  end

  def get_day_options date do
    1..Date.days_in_month date
  end
end
