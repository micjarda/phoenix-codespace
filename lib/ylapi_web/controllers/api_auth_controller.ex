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

  # Překlad chybových hlášek do čitelné podoby
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
end
