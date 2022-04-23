defmodule CometoidWeb.DateFormHelpers do

  def put_back_event params, previous_params, key do
    if not Map.has_key? params, key do
      Map.put params, key, previous_params[key]
    else
      params
    end
  end
end
