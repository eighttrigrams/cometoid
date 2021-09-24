defmodule CometoidWeb.IssueLive.SidebarComponent do
  # If you generated an app with mix phx.new --live,
  # the line below would be: use MyAppWeb, :live_component
  use Phoenix.LiveComponent

  def convert what do
    {:ok, html, _} = Earmark.as_html(what)
    html
    # String.split(what, ~r{(\r\n|\r|\n)})
  end
end
