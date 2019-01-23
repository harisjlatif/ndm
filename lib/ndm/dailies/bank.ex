defmodule Ndm.Dailies.Bank do
  require Logger
  import Ndm.Dailies.Utils
  use GenServer
  use Timex
  @interval 2000
  @daily "Bank"

  def execute() do
    case Ndm.HttpUtils.visit_url("http://www.neopets.com/process_bank.phtml", [type: "interest"]) do
      _ ->
        # Return the time that it was executed
        get_nst()
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
