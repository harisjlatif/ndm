defmodule Ndm.Crawler do
  use GenServer

  def start_link() do
    IO.puts("Started page crawl monitor")
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def add_url(url) do
    GenServer.cast(__MODULE__, {:queue, url})
  end

  def start(interval) do
    schedule_work(interval)
    # Log to channel the page being visited
  end

  def stop() do
    GenServer.cast(__MODULE__, :stop)
  end

  def get_pf_count() do
    GenServer.call(__MODULE__, :get_state)
  end

  def handle_call(:get_state, _from, list) do
    {:reply, length(list), list}
  end

  def handle_cast({:queue, item}, list) do
    {:noreply, list ++ [item]}
  end

  def handle_cast(:stop, _state) do
    # Log to channel that the crawler is being stopped
    {:noreply, []}
  end

  def handle_info({:work, interval}, state) do
    Ndm.HttpUtils.visit_url("http://www.neopets.com/random.phtml")
  end

  defp schedule_work(interval) do
    interval = Enum.random(interval-1..interval+1)
    Process.send_after(__MODULE__, {:work, interval}, interval)
  end
end
