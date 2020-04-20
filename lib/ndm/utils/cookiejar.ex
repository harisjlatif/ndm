defmodule Ndm.Utils.CookieJar do
  def new(username) do
    {:ok, _pid} =
      DynamicSupervisor.start_child(
        Ndm.CookieJarSupervisor,
        %{
          id: CookieJar,
          start: {CookieJar, :start_link, [[name: via_tuple(username)]]}
        }
      )
  end

  def via_tuple(username) do
    {:via, Registry, {Ndm.CookieJarRegistry, username}}
  end
end
