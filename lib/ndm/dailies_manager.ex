defmodule Ndm.DailiesManager do
  use Agent

  @doc """
  Starts a new bucket.
  """
  def start_link() do
    Agent.start_link(fn -> MapSet.new end, name: __MODULE__)
  end

  def add_daily(module, name) do
    module.start_link()
    Agent.update(__MODULE__, fn c -> MapSet.put(c, %{module: module, name: name}) end)
  end

  def get_dailies() do
    Agent.get(__MODULE__, fn c -> c end)
  end
end
