defmodule YlapiWeb.TokenController do
  use YlapiWeb, :controller

  alias Ylapi.Accounts
  def index(conn, _params) do
    testvar = "hahaha"
    user_id = get_session(conn, :user_id)  # Získání uživatelského ID ze session

    user = case user_id do
      nil -> nil  # Pokud není uživatel přihlášen
      _ -> Accounts.get_user!(user_id)  # Načtení uživatele podle ID
    end

    if user do
      # Uživatel je autentizován, načtěte tokeny a renderujte dashboard
      tokens = Accounts.list_user_api_tokens(user.id)
      render(conn, "index.html", tokens: tokens, testvar: testvar)
    else
      # Uživatel není autentizován, přesměrování
      conn
      |> put_flash(:error, "User not found or not authenticated.")
      |> redirect(to: "/")
    end
  end
  def revoke(conn, %{"id" => token_id}) do
    # Získání aktuálně přihlášeného uživatele
    user = Guardian.Plug.current_resource(conn)

    # Zneplatnění tokenu
    case Accounts.revoke_api_token(user, token_id) do
      {:ok, _token} ->
        # Pokud byl token úspěšně zneplatněn, zobrazí zprávu
        conn
        |> put_flash(:info, "Token was successfully revoked.")
        |> redirect(to: ~p"/tokens")

      {:error, _reason} ->
        # Pokud se nepodařilo zneplatnit token, zobrazí chybu
        conn
        |> put_flash(:error, "Unable to revoke token.")
        |> redirect(to: ~p"/tokens")
    end
  end
end
