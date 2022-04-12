defmodule CometoidWeb.Helpers do

  def convert raw do # TODO put this somewhere else
    case Earmark.as_html raw do
      {:ok, html, _} -> html
      _ -> raw
    end
  end
end
