defmodule YlapiWeb.SessionController do
  use YlapiWeb, :controller
  alias Ylapi.Accounts
  alias Ylapi.Guardian

  def create(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        # Vygenerování JWT tokenu pomocí Guardian
        {:ok, token, claims} = Guardian.encode_and_sign(user)

        # Získání expirace tokenu z claims
        expires_at = DateTime.from_unix!(claims["exp"])

        # Uložíme token do databáze
        Accounts.create_api_token(%{
          user_id: user.id,
          token: token,
          expires_at: expires_at
        })

        # Odpověď s tokenem
        json(conn, %{token: token})

      {:error, _reason} ->
        # Pokud autentizace selže, vrátí chybovou odpověď
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials"})
    end
  end
end
