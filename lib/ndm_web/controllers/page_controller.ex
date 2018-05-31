defmodule NdmWeb.PageController do
  use NdmWeb, :controller

  def index(conn, _params) do
    case Ndm.HttpUtils.visit_url("http://www.neopets.com/bank.phtml") do
      :loggedout ->
        conn
        |> Guardian.Plug.sign_out
        |> put_flash(:info, "Logged out")
        |> redirect(to: "/")
      {:ok, _response} ->
        Ndm.HttpUtils.visit_url("http://www.neopets.com/market.phtml?type=till")
        render conn, "index.html"
    end
  end

  def dailies(conn, _params) do
    case Ndm.HttpUtils.visit_url("http://www.neopets.com/bank.phtml") do
      :loggedout ->
        conn
        |> Guardian.Plug.sign_out
        |> put_flash(:info, "Logged out")
        |> redirect(to: "/")
      {:ok, _response} ->
        render conn, "dailies.html"
      {:error, _} ->
        IO.puts("Unable to visit bank, maybe time out")
        render conn, "dailies.html"
    end
  end
end
