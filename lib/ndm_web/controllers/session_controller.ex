defmodule NdmWeb.SessionController do
  use NdmWeb, :controller

  def new(conn, _params) do
    render(conn, "new.html")
  end

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, %{"session" => params}) do
    case CookieJar.HTTPoison.post(Ndm.Cookies, "http://www.neopets.com/login.phtml", {:form, [username: params["username"], password: params["password"]]}) do
      {:ok, %HTTPoison.Response{status_code: 302}} ->
        conn
        |> put_session(:current_user_id, params["username"])
        |> put_flash(:info, "Signed in successfully.")
        |> redirect(to: Routes.page_path(conn, :index))
      {:ok, _} ->
        conn
        |> put_flash(:error, "There was a problem with your username/password")
        |> render("new.html")
      {:error, _response} ->
        conn
        |> put_flash(:error, "There was a problem with the connection, try again later")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:current_user_id)
    |> put_flash(:info, "Signed out successfully.")
    |> redirect(to: Routes.session_path(conn, :new))
  end
end
