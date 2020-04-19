defmodule Ndm.Dailies.FruitMachine do
  require Logger
  import Ndm.Dailies.Utils
  use GenServer
  use Timex
  @interval 2000
  @daily "FruitMachine"

  def execute() do
    case Ndm.HttpUtils.visit_url("http://www.neopets.com/desert/fruit/index.phtml") do
      {:ok, response} ->
        msg = Floki.parse(response.body) |> Floki.find(".content")
        if (String.contains?(msg |> Floki.text, "You've already had your free spin for today")) do
          "You've already had your free spin for today. Please come back tomorrow and try again." |> NdmWeb.DailiesChannel.broadcast_lastresult_update(@daily)
          get_nst()
        else
          [spin, ck, _] = msg |> Floki.find(".result") |> Floki.attribute("input", "value")
          case Ndm.HttpUtils.visit_url("http://www.neopets.com/desert/fruit/index.phtml", [spin: spin, ck: ck]) do
            {:ok, play_response} ->
              Floki.parse(play_response.body) |> Floki.find("#fruitResult") |> Floki.text |> NdmWeb.DailiesChannel.broadcast_lastresult_update(@daily)
              get_nst()
            _ ->
              log("error running execute play")
              nil
          end
        end
      _ ->
        log("error running execute")
        nil
    end
  end

  def handle_info({:work, interval}, state) do
    state = 
      if (Ndm.SessionManager.get_cookies != nil) do
        # If last_execution is nil we need to execute
        case Map.get(state, :last_execution) do
          nil -> # Execute the process
            log("Processing")
            Map.put(state, :last_execution, execute())
          last_execution -> # We have not expired the timer
            if (last_modified_expired?(@daily, last_execution)) do
              log("Timer has expired, resetting last modified")
              Map.delete(state, :last_execution)
            else
              broadcast_timer(@daily, last_execution)
              state
            end
        end
      else
        state
      end

    schedule_work(interval)
    {:noreply, state}
  end

  def start_link() do
    log("Started")
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    # Every 1 seconds ping the monitor and push a new timer
    schedule_work(@interval)
  end

  defp schedule_work(interval) do
    Process.send_after(__MODULE__, {:work, interval}, interval)
  end

  defp log(msg) do
    Logger.info("[Dailies] [#{@daily}] #{msg}")
  end

  def init(args) do
    {:ok, args}
  end
end
