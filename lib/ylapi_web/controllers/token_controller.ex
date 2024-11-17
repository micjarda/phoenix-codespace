defmodule YlapiWeb.TokenController do
  use YlapiWeb, :controller

  alias Ylapi.Accounts
  alias Ylapi.Accounts.UserApiToken
  alias Ylapi.Repo

  import Ecto.Query
  # def index(conn, _params) do
  #   user_id = get_session(conn, :user_id)  # Získání uživatelského ID ze session

  #   user = case user_id do
  #     nil -> nil  # Pokud není uživatel přihlášen
  #     _ -> Accounts.get_user!(user_id)  # Načtení uživatele podle ID
  #   end

  #   if user do
  #     # Uživatel je autentizován, načtěte tokeny a renderujte dashboard
  #     tokens = Accounts.list_user_api_tokens(user.id)
  #     # tokens = Repo.all(from t in UserApiToken, select: %{id: t.id, token: t.token, app_name: t.app_name})
  #     render(conn, "index.html", tokens: tokens)
  #   else
  #     # Uživatel není autentizován, přesměrování
  #     conn
  #     |> put_flash(:error, "User not found or not authenticated.")
  #     |> redirect(to: "/")
  #   end
  # end

  def index(conn, _params) do
    user_id = get_session(conn, :user_id)  # Získání uživatelského ID ze session

    user = case user_id do
      nil -> nil  # Pokud není uživatel přihlášen
      _ -> Accounts.get_user!(user_id)  # Načtení uživatele podle ID
    end

    if user do
      # Uživatel je autentizován, načtěte tokeny a renderujte dashboard
      tokens = Repo.all(
        from t in UserApiToken,
        where: t.user_id == ^user.id,
        select: %{id: t.id, token: t.token, app_name: t.app_name}
      )
      render(conn, "index.html", tokens: tokens)
    else
      # Uživatel není autentizován, přesměrování
      conn
      |> put_flash(:error, "User not found or not authenticated.")
      |> redirect(to: "/")
    end
  end


  def revoke(conn, %{"id" => token_id}) do
    # Předpokládáme, že uživatel je uložen v conn.assigns[:current_user]
    user = conn.assigns[:current_user]

    IO.inspect(user, label: "User")
    IO.inspect(token_id, label: "Token ID")

    if user do
      # Zneplatnění tokenu
      case Accounts.revoke_api_token(user, token_id) do
        {:ok, _token} ->
          conn
          |> put_flash(:info, "Token was successfully revoked.")
          |> redirect(to: ~p"/tokens")

        {:error, _reason} ->
          conn
          |> put_flash(:error, "Unable to revoke token.")
          |> redirect(to: ~p"/tokens")
      end
    else
      conn
      |> put_flash(:error, "User not authenticated.")
      |> redirect(to: ~p"/login")
    end
  end
end
