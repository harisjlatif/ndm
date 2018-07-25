defmodule Ndm.Dailies.AutoPricer do
  require Logger
  use GenServer
  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def run () do
    case Ndm.HttpUtils.visit_url("http://www.neopets.com/jelly/jelly.phtml", [type: "get_jelly"]) do
      {:ok, response} ->
        parsed_html = Floki.parse(response.body)
        if (parsed_html |> Floki.find("p") |> Floki.text |> String.contains?("There are no items in your shop")) do
          log("There are no items in your shop, there is nothing to price.")
        else

        end
      _ ->
        log("error running")
      end
  end

  defp log(msg) do
    Logger.info("[AutoPricer] #{msg}")
  end

  def init(args) do
    {:ok, args}
  end
end
