defmodule Ndm.SessionManager do
  use Agent

  @doc """
  Starts a new bucket.
  """
  def start_link() do
    map = %{:neopoints => "N/A", :bank => "N/A"}
    Agent.start_link(fn -> map end, name: __MODULE__)
  end

  @doc """
  Gets a value from the `bucket` by `key`.
  """
  def get(key) do
    Agent.get(__MODULE__, fn c -> Map.get(c, key) end)
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  """
  def put(key, value) do
    Agent.update(__MODULE__, fn c -> Map.put(c, key, value) end)
  end

  def get_cookies() do
    case Agent.get(__MODULE__, fn c -> Map.get(c, :jar) end) do
      nil ->
        IO.inspect("Cookie jar does not exist yet, creating a new one")
        {:ok, jar} = CookieJar.new
        Agent.update(__MODULE__, fn c -> Map.put(c, :jar, jar) end)
        jar
      jar ->
        IO.inspect("Found a cookie jar")
        jar
    end
  end

  def drop_cookies() do
    Agent.update(__MODULE__, fn c -> Map.delete(c, :jar) end)
  end

  def get_neopoints() do
    Agent.get(__MODULE__, fn c -> Map.get(c, :neopoints) end)
  end

  def get_bank() do
    Agent.get(__MODULE__, fn c -> Map.get(c, :bank) end)
  end
end
