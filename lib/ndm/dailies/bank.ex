defmodule Ndm.Dailies.Bank do
  require Logger
  use GenServer
  use Timex

  def start_link() do
    Logger.debug("[Dailies] Started Bank monitor")
    GenServer.start_link(__MODULE__, %{}, name: Myself)
  end

  def start() do
    # Every 1 seconds ping the monitor and push a new timer
    schedule_work(1000)
  end

  def handle_info({:work, interval}, state) do
    case Map.get(state, :lastmodified) do
      nil ->
        Map.put(state, :lastmodified, process_interest())
      lastmodified ->
        if (Timex.before?(lastmodified |> Timex.Timezone.end_of_day, Timex.now("America/Los_Angeles"))) do
          Map.put(state, :lastmodified, process_interest())
        end
    end

    broadcast_timer()
    schedule_work(interval)
  end

  defp broadcast_timer() do
    # Push the new timer to the page
    Timex.now("America/Los_Angeles")
    |> Timex.Timezone.end_of_day
    |> Timex.diff(Timex.now("America/Los_Angeles"), :duration)
    |> Timex.Duration.to_clock
    |> NdmWeb.DailiesChannel.broadcast_timer_update(__MODULE__)
  end

  defp schedule_work(interval) do
    Process.send_after(Myself, {:work, interval}, interval)
  end

  def process_interest() do
    case Ndm.HttpUtils.visit_url("http://www.neopets.com/process_bank.phtml", [type: "interest"]) do
      _ -> Timex.now("America/Chicago")
    end
  end
end
