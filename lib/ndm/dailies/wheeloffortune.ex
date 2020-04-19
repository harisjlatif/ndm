defmodule Ndm.Dailies.WheelOfFortune do
  require Logger
  import Ndm.Dailies.Utils
  use GenServer
  use Timex
  @interval 2000
  @daily "WheelOfFortune"

  def execute() do
    case Ndm.HttpUtils.visit_url("http://www.neopets.com/faerieland/springs.phtml", [type: "heal"]) do
      {:ok, response} ->
        msg = Floki.parse(response.body) |> Floki.find(".content") |> Floki.find("center") |> Floki.find("p")
        if (String.contains?(msg |> Floki.text, "Please try back later")) do
          "Sorry! My magic is not fully restored yet. Please try back later."
        else
          List.first(msg) |> Floki.text
        end
        |> NdmWeb.DailiesChannel.broadcast_lastresult_update(@daily)
        get_nst()
      _ ->
        log("error running execute")
        nil
    end
  end

  def start_link() do
    log("Started")
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    # Every 1 seconds ping the monitor and push a new timer
    schedule_work(@interval)
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
