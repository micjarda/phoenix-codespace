defmodule YlapiWeb.ApiUserController do
  use YlapiWeb, :controller
  def me(conn, _params) do
    user =
      conn.assigns.current_user
      |> Ylapi.Repo.preload(:metadata)

    json(conn, %{
      user: %{
        id: user.id,
        email: user.email,
        nickname: user.metadata.nickname,
        source: user.metadata.source,
        inserted_at: user.inserted_at
      }
    })
  end
end
