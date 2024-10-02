defmodule YlapiWeb.ProfileController do
  use YlapiWeb, :controller
  alias Ylapi.Guardian

  def show(conn, _params) do
    user = Guardian.Plug.current_resource(conn)  # Získá uživatele z tokenu
    case user do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "User not found"})
      _user ->
        json(conn, %{user: user})
    end
  end
end
