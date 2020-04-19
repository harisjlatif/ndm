defmodule Ndm.ItemUtils do
  def get_shop_items() do
    case Ndm.HttpUtils.visit_url("http://www.neopets.com/market.phtml?type=your") do
      {:ok, response} ->
        shop_list = Floki.parse(response.body) |> Floki.find(".content") |> Floki.find("td p:fl-contains('Items')") |> Floki.find("a:fl-contains('[')") |> Floki.attribute("href")
        Enum.map(shop_list, fn x -> 
          case Ndm.HttpUtils.visit_url("http://www.neopets.com/#{x}") do
            {:ok, response} -> Ndm.ItemUtils.handle_shop_page(response)
            {:error, _} -> 
              []
          end
        end) 
      {:error, _} ->
        IO.puts("Unable to visit shop, maybe time out")
        []
    end
  end

  def handle_shop_page(response) do
    Floki.parse(response.body) |> Floki.find("td[width=\"60\"]") |> Floki.find("b") |> Enum.map(fn x -> %{item_name: Floki.text(x), page: response.request_url} end)
  end
end