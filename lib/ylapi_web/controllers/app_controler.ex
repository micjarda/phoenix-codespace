defmodule YlapiWeb.AppController do
  use YlapiWeb, :controller

  alias Ylapi.Repo
  alias Ylapi.Accounts.UserApiToken
  import Ecto.Query

  def index(conn, _params) do
    user_id = get_session(conn, :user_id)

    if user_id do
      apps =
        Repo.all(
          from t in UserApiToken,
          where: t.user_id == ^user_id and not is_nil(t.app_name),
          distinct: t.app_name,
          select: %{app_name: t.app_name}
        )

      render(conn, :index, apps: apps)
    else
      conn
      |> put_flash(:error, "You must be logged in to view applications.")
      |> redirect(to: "/login")
    end
  end

  def show(conn, %{"id" => app_name}) do
    user_id = get_session(conn, :user_id)

    if user_id do
      tokens =
        Repo.all(
          from t in UserApiToken,
          where: t.user_id == ^user_id and t.app_name == ^app_name,
          select: %{
            id: t.id,
            token: t.token,
            expires_at: t.expires_at,
            revoked_at: t.revoked_at
          }
        )

      render(conn, :show, app_name: app_name, tokens: tokens)
    else
      conn
      |> put_flash(:error, "You must be logged in to view tokens.")
      |> redirect(to: "/login")
    end
  end
end
