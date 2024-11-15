defmodule ValentineWeb.Router do
  use ValentineWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ValentineWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ValentineWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/workspaces", WorkspaceLive.Index, :index
    live "/workspaces/new", WorkspaceLive.Index, :new
    live "/workspaces/:id/edit", WorkspaceLive.Index, :edit

    live "/workspaces/:id", WorkspaceLive.Show, :show

    live "/workspaces/:workspace_id/threats", WorkspaceLive.Threat.Index, :index
    live "/workspaces/:workspace_id/threats/new", WorkspaceLive.Threat.Show, :new
    live "/workspaces/:workspace_id/threats/:id", WorkspaceLive.Threat.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", ValentineWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:valentine, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ValentineWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
