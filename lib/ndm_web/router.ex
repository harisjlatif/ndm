defmodule NdmWeb.Router do
  use NdmWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :require_login do
    plug NdmWeb.Plugs.RequireLogin
  end

  scope "/", NdmWeb do
    pipe_through :browser

    resources "/", SessionController, only: [:new, :create]

    delete "/logout", SessionController, :delete
  end

  scope "/", NdmWeb do
    pipe_through [:browser, :require_login]

    resources "/", PageController, only: [:index]

    resources "/dailies", DailiesController, only: [:index, :show]
  end

  # Other scopes may use custom stacks.
  # scope "/api", NdmWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: NdmWeb.Telemetry
    end
  end
end
