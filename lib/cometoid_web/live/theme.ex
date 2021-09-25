defmodule CometoidWeb.Theme do
  def start_link do
    Agent.start_link(fn ->
      Application.fetch_env! :cometoid, :themes
    end, name: __MODULE__)
  end

  def get do
    %{ theme: List.first(Agent.get(__MODULE__, & &1)) }
  end

  def toggle do
    Agent.update(__MODULE__, fn old_val ->
      [selected_theme|themes] = old_val
      themes = themes ++ [selected_theme]
      %{ theme: selected_theme, themes: themes }
      themes
    end)
  end
end
