defmodule NdmWeb.PageController do
  use NdmWeb, :controller

  def index(conn, _params) do
    case Ndm.HttpUtils.visit_url("http://www.neopets.com/bank.phtml") do
      :loggedout ->
        conn
        |> Guardian.Plug.sign_out
        |> put_flash(:info, "Logged out")
        |> redirect(to: "/")
      :ok ->
        render conn, "index.html"
    end
  end

  def dailies(conn, _params) do
    render conn, "dailies.html"
  end
end
