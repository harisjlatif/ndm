defmodule NdmWeb.DailiesChannel do
  use NdmWeb, :channel
  @channel "dailies"

  ##
  # Test Call Switch Broadcast Messages
  ##
  def broadcast_timer_update({hour, minute, seconds, _}, module) do
    time = "Execute in: #{hour}:#{minute}:#{seconds}"
    NdmWeb.Endpoint.broadcast(@channel, "update_timer", %{module: module, time: time})
  end

  ##
  # Socket Join Handlers
  ##

  def join(@channel, _params, socket) do
    IO.inspect("Connected to dailies socket")
    send(self(), :after_join)
    {:ok, socket}
  end

  ##
  # Response Handlers
  ##
  def handle_info(:after_join, socket) do
    {:noreply, socket}
  end
end
