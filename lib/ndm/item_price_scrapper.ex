defmodule Ndm.ItemPriceScrapper do
  def fill_item_prices(items) do
    {:ok, item_prices} = get_item_prices()
    Enum.map(items, fn x -> %{:item_name => x, :item_price => Map.get(item_prices, x)} end)
  end

  def get_item_price(item) do
    case get_item_prices() do
      {:ok, prices} -> Enum.find(prices, fn x -> x == item end)
      {:error, _} -> "N/A"
    end
  end

  def get_item_prices do
    file_name_string = "price_list/#{Timex.format!(Timex.now, "items-%Y-%m.json", :strftime)}"
    case File.read(file_name_string) do
      {:ok, file} ->
        Poison.decode(file)
      {:error, _} ->
        IO.inspect("File not found will create a new one.")
        File.write(file_name_string, Poison.encode!(create_item_price_file(), pretty: true))
        Poison.decode(file_name_string)
    end
  end

  defp create_item_price_file do
    params = [app: "itemdb", module: "search", section: "search", item: "",
              description: "", rarity_low: "", rarity_high: "", price_low: "",
              price_high: "",shop: "", search_order: "price", sort: "asc", lim: "100"]
    {_, response} = HTTPoison.post("http://www.neocodex.us/forum/index.php", {:form, params})

    {page_count, _} =
      Floki.parse(response.body) |> Floki.find("a:fl-contains('Page')") |> Floki.text |> String.replace("Page 1 of ", "") |> String.replace(" ", "") |> Integer.parse

      Enum.reduce(0..page_count, %{}, fn x, acc ->
        st_value = Integer.to_string(x * 100)
        params = [app: "itemdb", module: "search", section: "search", item: "",
                description: "", rarity_low: "", rarity_high: "", price_low: "",
                price_high: "",shop: "", search_order: "price", sort: "asc", lim: "100",
                st: st_value]

        case HTTPoison.post("http://www.neocodex.us/forum/index.php", {:form, params}) do
          {:error, _} ->
            IO.inspect("Error")

            Map.merge(acc, %{})
          {:ok, response}->
            item_list_floki =
            Floki.parse(response.body) |> Floki.find(".general_box") |> Floki.find(".ipsList_inline") |> Floki.find("li")

            item_price_map =
              Enum.reduce(item_list_floki, %{}, fn x, acc ->
                item_name = Floki.find(x, ".desc") |> Floki.find("a") |> Floki.text |> String.trim
                item_price = Floki.find(x, ".desc") |> Floki.find(".idbQuickPrice") |> Floki.text
                Map.put(acc, item_name, item_price)
              end)

            IO.puts("Completed parsing page #{st_value}")

            Map.merge(acc, item_price_map)
        end
      end)
  end
end
