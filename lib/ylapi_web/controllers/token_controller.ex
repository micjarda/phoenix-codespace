defmodule YlapiWeb.TokenController do
  use YlapiWeb, :controller

  alias Ylapi.Accounts
  alias Ylapi.Accounts.UserApiToken
  alias Ylapi.Repo
  alias Phoenix.PubSub  # Přidáme PubSub alias

  import Ecto.Query

  @pubsub_topic "tokens"

  def index(conn, _params) do
    user_id = get_session(conn, :user_id)  # Získání uživatelského ID ze session

    user = case user_id do
      nil -> nil
      _ -> Accounts.get_user!(user_id)
    end

    if user do
      tokens = Repo.all(
        from t in UserApiToken,
        where: t.user_id == ^user.id,
        select: %{id: t.id, token: t.token, app_name: t.app_name}
      )
      render(conn, "index.html", tokens: tokens)
    else
      conn
      |> put_flash(:error, "User not found or not authenticated.")
      |> redirect(to: "/")
    end
  end

  def revoke(conn, %{"id" => token_id}) do
    user = conn.assigns[:current_user]

    if user do
      case Accounts.revoke_api_token(user, token_id) do
        {:ok, token} ->
          # 🔥 Odeslání zprávy do PubSub při revokaci tokenu
          PubSub.broadcast(Ylapi.PubSub, @pubsub_topic, {:token_revoked, token.id})

          conn
          |> put_flash(:info, "Token was successfully revoked.")
          |> redirect(to: ~p"/users/api/tokens")

        {:error, _reason} ->
          conn
          |> put_flash(:error, "Unable to revoke token.")
          |> redirect(to: ~p"/users/api/tokens")
      end
    else
      conn
      |> put_flash(:error, "User not authenticated.")
      |> redirect(to: ~p"/api/login")
    end
  end

  def create(conn, %{"token" => token_params}) do
    user = conn.assigns[:current_user]

    if user do
      case Accounts.create_api_token(token_params) do
        {:ok, token} ->
          # 🔥 Odeslání zprávy do PubSub při vytvoření tokenu
          PubSub.broadcast(Ylapi.PubSub, @pubsub_topic, {:token_created, token.id})

          conn
          |> put_flash(:info, "Token successfully created.")
          |> redirect(to: ~p"/users/api/tokens")

        {:error, _changeset} ->
          conn
          |> put_flash(:error, "Failed to create token.")
          |> redirect(to: ~p"/users/api/tokens")
      end
    else
      conn
      |> put_flash(:error, "User not authenticated.")
      |> redirect(to: ~p"/api/login")
    end
  end
end
