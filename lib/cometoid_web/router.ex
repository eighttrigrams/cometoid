defmodule CometoidWeb.Router do
  use CometoidWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {CometoidWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CometoidWeb do
    pipe_through :browser
    live "/", EventLive.Index, :index
    live "/events", EventLive.Index, :index
    live "/issues", IssueLive.Index, :index
  end
end
