defmodule YlapiWeb.SessionController do
  use YlapiWeb, :controller
  alias Ylapi.Accounts
  alias Ylapi.Guardian
  alias Phoenix.PubSub

  def create(conn, %{"email" => email, "password" => password, "app_name" => app_name}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, token, claims} = Guardian.encode_and_sign(user, %{}, token_type: "access")
        expires_at = DateTime.from_unix!(claims["exp"])

        case Accounts.create_api_token(%{
               user_id: user.id,
               token: token,
               expires_at: expires_at,
               app_name: app_name
             }) do
          {:ok, api_token} ->
            # Publikace nové zprávy
            Phoenix.PubSub.broadcast(
              Ylapi.PubSub,
              "user_tokens:#{user.id}",
              {:new_token, api_token}
            )

            conn
            |> put_resp_cookie("auth_token", token, http_only: false, max_age: 86400)
            |> json(%{token: token})

          {:error, changeset} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: "Failed to save token", details: changeset})
        end

      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})
    end
  end

end
