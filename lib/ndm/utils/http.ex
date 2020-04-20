defmodule Ndm.Utils.Http do
  def login(username, password) do
    # Create a new cookie jar to attempt a login
    Ndm.Utils.CookieJar.new(username)

    # Attempt to login using the provided username's CookieJar
    username
    |> post("http://www.neopets.com/login.phtml", login_opts(username, password))
    |> case do
      {:ok, %HTTPoison.Response{status_code: 302}} ->
        {:ok, username}

      {:ok, _} ->
        {:error, "There was a problem with your username/password"}

      {:error, _response} ->
        {:error, "There was a problem with the connection, try again later"}
    end
  end

  defp post(username, url, opts) do
    CookieJar.HTTPoison.post(Ndm.Utils.CookieJar.via_tuple(username), url, opts)
  end

  defp login_opts(username, password) do
    {:form, [username: username, password: password]}
  end
end
