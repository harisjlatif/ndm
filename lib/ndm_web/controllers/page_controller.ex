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

  def inventory(conn, _params) do
    items =
    case Ndm.HttpUtils.visit_url("http://www.neopets.com/inventory.phtml") do
      :loggedout ->
        conn
        |> Guardian.Plug.sign_out
        |> put_flash(:info, "Logged out")
        |> redirect(to: "/")
      {:ok, response} ->
          Floki.parse(response.body) |> Floki.find(".content") |> Floki.find(".inventory") |> Floki.find("td") |> Floki.text 
          |> String.split(["\n", "(special)", "(rare)", "(uncommon)", "(MEGA RARE)", "(ultra rare)"], trim: true)
          |> Enum.reject(fn x -> x == "(special)" end)
          |> Enum.reject(fn x -> x == "(Neocash)" end)
          |> Enum.map(fn x -> %{:item_name => x, :item_price => 0} end)
      {:error, _} ->
        IO.puts("Unable to visit inventory, maybe time out")
        %{}
    end

    render(conn, "inventory.html", items: items)
  end

#  def shop(conn, _params) do
#    items =
#    case Ndm.HttpUtils.visit_url("http://www.neopets.com/inventory.phtml") do
#      :loggedout ->
#        conn
#        |> Guardian.Plug.sign_out
#        |> put_flash(:info, "Logged out")
#        |> redirect(to: "/")
#      {:ok, response} ->
#          
#      {:error, _} ->
#        IO.puts("Unable to visit shop, maybe time out")
#        %{}
#    end
#
#    render(conn, "shop.html", items: items)
#  end
end