defmodule Ndm.Dailies.LunarTemple do
  require Logger
  import Ndm.Dailies.Utils
  use GenServer
  use Timex
  @interval 2000
  @daily "LunarTemple"

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
          found_angle_string = Regex.run(~r/angleKreludor=[+-]?([0-9]*[.])?[0-9]+&/, text) |> Floki.text |> String.trim("angleKreludor=") |> String.trim("&")

          {angle_float, _} = Float.parse(found_angle_string)
          angle = trunc(Float.round(angle_float / 22.5))

          log("Determined #{angle} for #{found_angle_string} as the answer")
          case Ndm.HttpUtils.visit_url("http://www.neopets.com/shenkuu/lunar/results.phtml", [submitted: "true", phase_choice: angle]) do
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
