defmodule NdmWeb.DailiesController do
  use NdmWeb, :controller

  def index(conn, _params) do
    render(conn, "dailies.html")
  end

  def show(conn, _params) do
    render(conn, "daily.html")
  end
end
