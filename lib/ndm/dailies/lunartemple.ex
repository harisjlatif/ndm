defmodule Ndm.Dailies.LunarTemple do
  require Logger
  use GenServer
  use Timex
  @interval 2000
  @daily "LunarTemple"
  @nst "America/Los_Angeles"

  def execute() do
    case Ndm.HttpUtils.visit_url("http://www.neopets.com/shenkuu/lunar/?show=puzzle") do
      {:ok, response} ->
        msg = Floki.parse(response.body) |> Floki.find(".content")
        if (String.contains?(msg |> Floki.text, "Please try again tomorrow")) do
          "The wise Gnorbu says: 'You may only attempt my challenge once per day. Please try again tomorrow!'"
          |> NdmWeb.DailiesChannel.broadcast_lastresult_update(@daily)
          get_nst()
        else
          text = msg |> Floki.find("div script:nth-child(2)") |> Floki.text([js: true])
          found_angle_string = Regex.run(~r/angleKreludor=\d\d\d/, text) |> Floki.text |> String.trim("angleKreludor=")
          {angle, _} = Integer.parse(found_angle_string)
          selection = to_string(trunc(Float.round(angle/22.5)))

          case Ndm.HttpUtils.visit_url("http://www.neopets.com/shenkuu/lunar/results.phtml", [submitted: "true", phase_choice: selection]) do
            {:ok, submit_response} ->
              Floki.parse(submit_response.body) |> Floki.find(".content") |> Floki.text |> NdmWeb.DailiesChannel.broadcast_lastresult_update(@daily)
              get_nst()
            _ ->
              log("error running execute")
              nil
          end
        end
      _ ->
        log("error running execute")
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
