defmodule NdmWeb.Router do
  use NdmWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
  end

  pipeline :browser_session do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :require_login do
    plug Guardian.Plug.EnsureAuthenticated,
      handler: NdmWeb.AuthController
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NdmWeb do
    pipe_through :browser

    get "/login", AuthController, :new_url

    get "/login.html", AuthController, :new
    post "/login.html", AuthController, :create

    get "/logout.html", AuthController, :logout
  end

  scope "/", NdmWeb do
    pipe_through [:browser, :browser_session, :require_login]

    get "/", PageController, :index
    get "/index.html", PageController, :index
    get "/dailies.html", PageController, :dailies
  end

  # Other scopes may use custom stacks.
  # scope "/api", NdmWeb do
  #   pipe_through :api
  # end
end
