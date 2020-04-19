defmodule Ndm.Dailies.AppleBobbing do
  require Logger
  import Ndm.Dailies.Utils
  use GenServer
  use Timex
  @interval 2000
  @daily "AppleBobbing"

  def execute() do
    case Ndm.HttpUtils.visit_url("http://www.neopets.com/halloween/applebobbing.phtml?bobbing=1") do
      {:ok, response} ->
        msg = Floki.parse(response.body) |> Floki.find("#bob_middle")
        if (String.contains?(msg |> Floki.text, "Away with you, then, until tomorrow")) do
          "Away with you, then, until tomorrow"
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
