defmodule Ndm.SessionManager do
  require Logger
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
    Agent.get(__MODULE__, fn c -> Map.get(c, :jar) end)
  end

  def drop_cookies() do
    Logger.debug("Dropping cookies")
    Agent.update(__MODULE__, fn c -> Map.delete(c, :jar) end)
  end

  def get_neopoints() do
    Agent.get(__MODULE__, fn c -> Map.get(c, :neopoints) end)
  end

  def get_bank() do
    Agent.get(__MODULE__, fn c -> Map.get(c, :bank) end)
  end

  def new_cookie_jar() do
    Logger.debug("Creating new cookie jar")
    {:ok, jar} = CookieJar.new
    Agent.update(__MODULE__, fn c -> Map.put(c, :jar, jar) end)
  end
end
