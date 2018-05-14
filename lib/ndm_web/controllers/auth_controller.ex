defmodule NdmWeb.AuthController do
  use NdmWeb, :controller

  @doc """
  Handles requests from unauthenticated users and redirects them to the login page.
  """
  def unauthenticated(conn, _params) do
    # If the user accesses any page without begin autheticated, redirect them to login page
    redirect(conn, to: auth_path(conn, :new))
  end

  @doc """
  Handles requests from unauthenticated users and redirects them to the login page.
  """
  def unauthorized(conn, _params) do
    # If the user accesses any page without begin autheticated, redirect them to login page
    conn
    |> put_flash(:info, "Not authorized to access that page")
    |> redirect(to: "/")
  end

  @doc """
  Handles the requests to display the login page.
  """
  def new(conn, _params) do
    render conn, "login.html"
  end

  @doc """
  Handles the requests to display the login page.
  """
  def new_url(conn, _params) do
    create(conn, %{"login" => conn.params})
  end

  @doc """
  Handles the requests to out the user out.
  """
  def logout(conn, _params) do
    conn
    |> Guardian.Plug.sign_out
    |> put_flash(:info, "Logged out")
    |> redirect(to: "/")
  end

  def signed_in(conn, username, permissions) do
    conn
    # Create a Guardian session for the provided username
    |> Guardian.Plug.sign_in(username, :token, perms: permissions)
    |> redirect(to: "/")
  end

  def error_in(conn) do
    conn
    |> put_flash(:error, "Incorrect username or password")
    |> render("login.html")
  end

  @doc """
  Handles the request to create a new user session using the provided username and password. This
  information is validated using the current backing Apache HTPASSWD file. A correct login
  will allow the user to access the remaining web pages. An incorrect login will report an error
  and allow the user to try and re-login.
  """
  def create(conn, %{"login" => %{"username" => username, "password" => password}}) do
    # Check if the credentials provided at login page are valid
    case authenticate(username, password) do
      :user ->
        IO.inspect("User #{username} authenticated successfully")
        signed_in(conn, username, %{user: [:default]})
      :error ->
        IO.inspect("User #{username} authentication failed")
        error_in(conn)
    end
  end

  def create(conn, _) do
    # Check if the credentials provided at login page are valid
    conn
    |> put_flash(:error, "Incorrect username or password")
    |> render("login.html")
  end

  @doc """
  Destroys the saved user session, causing them to logout.
  """
  def destroy(conn, _params) do
    conn
    # Remove the user's session
    |> Guardian.Plug.sign_out
    # Send the user back to homepage which will redirect to login since no session exists
    |> redirect(to: "/")
  end

  defp authenticate(username, password) do
    case Ndm.HttpUtils.login(username, password) do
      # If the credentials exist in the htpasswd file then mark the username as authenticated
      :ok -> :user
      # If the credentials are invalid, no session is created
      _ -> :error
    end
  end

end
