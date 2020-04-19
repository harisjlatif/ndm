defmodule Ndm.HttpUtils do

  def login(username, password) do
    {:ok, jar} = CookieJar.new
    case CookieJar.HTTPoison.post(jar, "http://www.neopets.com/login.phtml", {:form, [username: username, password: password]}) do
      {:ok, %HTTPoison.Response{status_code: 302}} ->
        Ndm.SessionManager.put_cookie_jar(jar)
        IO.inspect("Successfully connected")
        :ok
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        IO.inspect("Incorrect login information")
        Ndm.SessionManager.drop_cookies
        :error
      {:ok, _} ->
        IO.inspect("Unhandled request")
        :error
      {:error, _response} ->
        IO.inspect("Unable to connect to login")
        :error
    end
  end

  def visit_url(url) do
    case Ndm.SessionManager.get_cookies do
      nil ->
        :loggedout
      jar ->
        case CookieJar.HTTPoison.get(jar, url, [{"User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36"}]) do
          {:ok, response} ->
            handle_response(response)
            {:ok, response}
          {:error, response} ->
            IO.inspect("Error trying to access url #{url}")
            {:error, response}
        end
    end
  end

  def visit_url(url, params) do
    case CookieJar.HTTPoison.post(Ndm.SessionManager.get_cookies, url, {:form, params}) do
      {:ok, response = %HTTPoison.Response{status_code: 200}} ->
        handle_response(response)
        {:ok, response}
      {:ok, response = %HTTPoison.Response{request_url: "http://www.neopets.com/process_bank.phtml"}} ->
        handle_response(response)
        {:ok, response}
      {:error, response} ->
        IO.inspect("Unable to connect #{url}")
        {:error, response}
    end
  end

  def visit_url(url, params, headers) do
    case CookieJar.HTTPoison.post(Ndm.SessionManager.get_cookies, url, {:form, params}, headers) do
      {:ok, response = %HTTPoison.Response{status_code: 200}} ->
        handle_response(response)
        {:ok, response}
      {:error, response} ->
        IO.inspect("Unable to connect #{url}")
        {:error, response}
    end
  end

  def handle_response(response) do
    response |> update_np |> update_bank |> update_till |> update_items_stocked
  end

  def update_np(response) do
    Ndm.SessionManager.put(:neopoints, (Floki.parse(response.body) |> Floki.find("#npanchor") |> Floki.text) <> " NP")
    response
  end

  def update_bank(response) do
    if (response.request_url == "http://www.neopets.com/bank.phtml") do
      [first, _second] = Floki.parse(response.body) |> Floki.find(".contentModuleContent") |> Floki.find("form") |> Floki.find("td + td") |> Floki.find("b")
      Ndm.SessionManager.put(:bank, Floki.text(first))
    end
    response
  end

  def update_till(response) do
    if (response.request_url == "http://www.neopets.com/market.phtml?type=till") do
      Ndm.SessionManager.put(:till, Floki.parse(response.body) |> Floki.find(".content > p > b") |> Floki.text)
    end
    response
  end

  def update_items_stocked(response) do
    if (response.request_url == "http://www.neopets.com/market.phtml?type=your") do
      list = Floki.parse(response.body) |> Floki.find(".content") |> Floki.find("td p") |> Floki.find("p:fl-contains('Items')") |> Floki.find("center") |> Floki.find("b")
      {_, _, items_stocked} = Enum.at(list, 1)
      {_, _, free_space} = Enum.at(list, 2)
      Ndm.SessionManager.put(:stocked, items_stocked)
      Ndm.SessionManager.put(:free, free_space)
    end
  end
end
