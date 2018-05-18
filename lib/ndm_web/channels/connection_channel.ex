defmodule NdmWeb.ConnectionChannel do
  use NdmWeb, :channel
  @channel "connection"

  ##
  # Test Call Switch Broadcast Messages
  ##
  def broadcast_timer_update({hour, minute, seconds, _}, module) do
    time = "Execute in: #{hour}:#{minute}:#{seconds}"
    IO.inspect(time)
    NdmWeb.Endpoint.broadcast(@channel, "update_timer", %{module: module, time: time})
  end

  ##
  # Socket Join Handlers
  ##

  def join(@channel, _params, socket) do
    IO.inspect("Connected to Connection socket")
    {:ok, socket}
  end
end
