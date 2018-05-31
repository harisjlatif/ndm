defmodule Ndm.Dailies.ForgottenShore do
  require Logger
  use GenServer
  use Timex
  @interval 2000
  @daily "ForgottenShore"
  @nst "America/Los_Angeles"

  def execute() do
    case Ndm.HttpUtils.visit_url("http://www.neopets.com/pirates/forgottenshore.phtml") do
      {:ok, response} ->
        # Check if we've visited already today
        msg = Floki.parse(response.body) |> Floki.find(".content")
        if (String.contains?(msg |> Floki.text, "You've already searched the coast for treasure today")) do
          "You've already searched the coast for treasure today. Perhaps you should try again tomorrow."
          |> NdmWeb.DailiesChannel.broadcast_lastresult_update(@daily)
        else
          # First time today
          if (String.contains?(msg |> Floki.text, "but there's nothing of interest to be found today")) do
            "A deserted shore stretches along in front of you, but there's nothing of interest to be found today."
            |> NdmWeb.DailiesChannel.broadcast_lastresult_update(@daily)
          else
            url = msg |> Floki.find("#shore_back") |> Floki.find("a") |> Floki.attribute("href") |> Floki.text
            if (String.contains?(url, "confirm")) do
              case Ndm.HttpUtils.visit_url("http://www.neopets.com/pirates/forgottenshore.phtml#{url}") do
                {:ok, confirm_response} ->
                  Floki.parse(confirm_response.body) |> Floki.find(".content") |> Floki.find("center") |> Floki.text
                  |> NdmWeb.DailiesChannel.broadcast_lastresult_update(@daily)
                _ ->
                  nil
              end
            else
              msg |> Floki.find("#shore_back")
              |> NdmWeb.DailiesChannel.broadcast_lastresult_update(@daily)
            end
          end
        end
        get_nst()
      _ ->
        nil
    end
  end

  def time_till_execution(last_execution) do
    last_execution |> Timex.Timezone.end_of_day
  end

  def start_link() do
    log("Started")
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    # Every 1 seconds ping the monitor and push a new timer
    schedule_work(@interval)
  end

  defp broadcast_timer(last_execution) do
    # Push the new timer to the page
    time_till_execution(last_execution)
    |> Timex.diff(get_nst(), :duration)
    |> Timex.Duration.to_clock
    |> NdmWeb.DailiesChannel.broadcast_timer_update(@daily)
  end

  defp last_modified_expired?(last_execution) do
    Timex.before?(time_till_execution(last_execution), get_nst())
  end

  defp get_nst() do
    Timex.now(@nst)
  end

  def handle_info({:work, interval}, state) do
    state = if (Ndm.SessionManager.get_cookies != nil) do
      case Map.get(state, :last_execution) do
        nil ->
          log("Processing")
          Map.put(state, :last_execution, execute())
          last_execution ->
          if (last_modified_expired?(last_execution)) do
            log("Timer has expired, resetting last modified")
            Map.delete(state, :last_execution)
          else
            broadcast_timer(last_execution)
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
