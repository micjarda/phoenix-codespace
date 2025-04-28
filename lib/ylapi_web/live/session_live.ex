defmodule YlapiWeb.SessionManager do
  import Ecto.Query
  alias Ylapi.Repo
  alias Ylapi.Accounts.UserApiToken
  alias YlapiWeb.Endpoint

  def logout_user(user_id) do
    # Smažeme všechny API tokeny uživatele (aby ho už nikdo neautorizoval)
    from(t in UserApiToken, where: t.user_id == ^user_id)
    |> Repo.delete_all()

    # A pošleme všem jeho websocketům zprávu "logout"
    Endpoint.broadcast!("user_session:#{user_id}", "logout", %{})
  end
end
