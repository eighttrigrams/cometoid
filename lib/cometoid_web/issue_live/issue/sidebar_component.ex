defmodule CometoidWeb.IssueLive.Issue.SidebarComponent do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_component
  use Phoenix.LiveComponent

  def convert raw do # TODO put this somewhere else
    case Earmark.as_html raw do
      {:ok, html, _} -> html
      _ -> raw
    end
  end
end
