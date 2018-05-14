defmodule NdmWeb.PageController do
  use NdmWeb, :controller

  def index(conn, _params) do
    Ndm.HttpUtils.visit_url("http://www.neopets.com/bank.phtml")
    render conn, "index.html"
  end
end
