defmodule Ndm.Dailies.Bank do
  require Logger
  use GenServer
  use Timex

  def start_link() do
    Logger.debug("[Dailies] Started Bank monitor")
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    # Every 1 seconds ping the monitor and push a new timer
    schedule_work(1000)
  end

  def handle_info({:work, interval}, state) do
    state = if (Ndm.SessionManager.get_cookies != nil) do
      case Map.get(state, :lastmodified) do
        nil ->
          Map.put(state, :lastmodified, process_interest())
        lastmodified ->
          if (Timex.before?(lastmodified |> Timex.Timezone.end_of_day, Timex.now("America/Los_Angeles"))) do
            Logger.debug("[Daily] [Bank] New day has arrived, ressetting last modified")
            Map.delete(state, :lastmodified)
          else
            broadcast_timer()
            state
          end
      end
    else
      state
    end

    schedule_work(interval)
    {:noreply, state}
  end

  defp broadcast_timer() do
    # Push the new timer to the page
    Timex.now("America/Los_Angeles")
    |> Timex.Timezone.end_of_day
    |> Timex.diff(Timex.now("America/Los_Angeles"), :duration)
    |> Timex.Duration.to_clock
    |> NdmWeb.DailiesChannel.broadcast_timer_update("Bank")
  end

  defp schedule_work(interval) do
    Process.send_after(__MODULE__, {:work, interval}, interval)
  end

  def process_interest() do
    Logger.info("[Daily] [Bank] Processing")
    case Ndm.HttpUtils.visit_url("http://www.neopets.com/process_bank.phtml", [type: "interest"]) do
      _ -> Timex.now("America/Chicago")
    end
  end
end
