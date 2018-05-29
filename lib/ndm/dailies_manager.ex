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
    lastresult = "N/A"
    Agent.update(__MODULE__, fn c -> MapSet.put(c, %{module: module, name: name, lastresult: lastresult}) end)
  end

  def update_daily_result(name, lastresult) do
    Agent.update(__MODULE__, fn c ->
      MapSet.new(c, fn %{name: ^name} =
        old -> Map.put(old, :lastresult, lastresult)
        any -> any
      end)
    end)
  end

  def get_dailies() do
    Agent.get(__MODULE__, fn c -> c end)
  end
end
