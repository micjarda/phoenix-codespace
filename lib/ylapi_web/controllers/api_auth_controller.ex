defmodule YlapiWeb.ApiAuthController do
  use YlapiWeb, :controller

  alias Ylapi.Accounts
  alias YlapiWeb.Auth.Guardian

  def register(conn, %{"email" => email, "password" => pw, "nickname" => nick}) do
    case Accounts.register_user_with_metadata(%{
      "email" => email,
      "password" => pw,
      "nickname" => nick,
      "source" => "autosuki"
    }) do
      {:ok, user} ->
        {:ok, token, _} = Guardian.encode_and_sign(user)

        json(conn, %{
          token: token,
          user: %{
            id: user.id,
            email: user.email
          }
        })

      {:error, changeset} ->
        conn
        |> put_status(:bad_request)
        |> json(%{
          errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
        })
    end
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)

        json(conn, %{
          token: token,
          user: %{
            id: user.id,
            email: user.email
          }
        })

      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid email or password"})
    end
  end

  def login(conn, %{"username" => username, "password" => password, "app_name" => app_name}) do
    case Accounts.authenticate_user(username, password) do
      {:ok, user} ->
        case Accounts.generate_user_api_token(user, app_name) do
          {:ok, token} ->
            conn
            |> put_resp_cookie("yl_token", token, max_age: 60 * 60 * 24 * 30, http_only: true)
            |> json(%{status: "ok", token: token, user_id: user.id})

          {:error, reason} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: "Could not generate token", reason: inspect(reason)})
        end

      {:error, reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: reason})
    end
  end

  def logout(conn, _) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        case Ylapi.Accounts.get_user_api_token(token) do
          nil ->
            send_resp(conn, 401, "Invalid token")

          %Ylapi.Accounts.UserApiToken{user_id: user_id} = token_record ->
            # Revoke token
            Ylapi.Accounts.revoke_api_token(token_record.token)
            # Broadcast logout všem socketům toho uživatele
            YlapiWeb.Endpoint.broadcast("user_session:#{user_id}", "logout", %{})
            send_resp(conn, 200, "Logged out")
        end

      _ ->
        send_resp(conn, 401, "Missing Authorization header")
    end
  end
end
