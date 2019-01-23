defmodule Ndm.Dailies.Utils do
  require Logger
  use Timex
  @nst "America/Los_Angeles"

  def get_nst() do
    Timex.now(@nst)
  end

  def broadcast_timer(daily, last_execution) do
    # Push the new timer to the page
    time_till_execution(daily, last_execution)
    |> Timex.diff(get_nst(), :duration)
    |> Timex.Duration.to_clock
    |> NdmWeb.DailiesChannel.broadcast_timer_update(daily)
  end

  def last_modified_expired?(daily, last_execution) do
    time_till_execution(daily, last_execution)
    |> Timex.before?(get_nst())
  end

  def time_till_execution(daily, last_execution) do
    case daily do
      "AnchorManagement" -> Timex.Timezone.end_of_day(last_execution)
      "AppleBobbing" -> Timex.Timezone.end_of_day(last_execution)
      "Bank" -> Timex.Timezone.end_of_day(last_execution)
      "Fishing" -> Timex.Timezone.end_of_day(last_execution)
      "ForgottenShore" -> Timex.Timezone.end_of_day(last_execution)
      "FruitMachine" -> Timex.Timezone.end_of_day(last_execution)
      "Jelly" -> Timex.Timezone.end_of_day(last_execution)
      "LunarTemple" -> Timex.Timezone.end_of_day(last_execution)
      "Omlette" -> Timex.Timezone.end_of_day(last_execution)
      "Springs" -> Timex.shift(last_execution, minutes: 31)
      "TDMBGPOP" -> Timex.Timezone.end_of_day(last_execution)
      "Tomb" -> Timex.Timezone.end_of_day(last_execution)
      "Tombola" -> Timex.Timezone.end_of_day(last_execution)
      #"WheelOfFortune" ->
    end
  end
end