defmodule Ndm.HttpUtils do

  def login(username, password) do
    case CookieJar.HTTPoison.post(Ndm.SessionManager.get_cookies, "http://www.neopets.com/login.phtml", {:form, [username: username, password: password]}) do
      {:ok, %HTTPoison.Response{status_code: 302}} ->
        IO.inspect("Successfully connected")
        :ok
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        IO.inspect("Incorrect login information")
        :error
      {:ok, _} ->
        IO.inspect("Unhandled request")
        :error
      {:error, response} ->
        IO.inspect("Unable to connect")
        :error
    end
  end

  def visit_url(url) do
    case CookieJar.HTTPoison.get(Ndm.SessionManager.get_cookies, url) do
      {:ok, response = %HTTPoison.Response{status_code: 200}} ->
        update_np(response.body)
        update_bank(response)
        :ok
      {:error, response} ->
        IO.inspect("Unable to connect")
        :error
    end
  end

  def update_np(body) do
    Ndm.SessionManager.put(:neopoints, (Floki.parse(body) |> Floki.find("#npanchor") |> Floki.text) <> " NP")
  end

  def update_bank(response) do
    if (response.request_url == "http://www.neopets.com/bank.phtml") do
      [first, second] = Floki.parse(response.body) |> Floki.find(".contentModuleContent") |> Floki.find("form") |> Floki.find("td + td") |> Floki.find("b")
      Ndm.SessionManager.put(:bank, Floki.text(first))
    end
  end
end
