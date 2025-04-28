defmodule YlapiWeb.SessionManager do
  alias YlapiWeb.Endpoint

  @doc """
  Vykopne všechny připojené sockety uživatele.
  """
  def logout_user(user_id) do
    Endpoint.broadcast("user_session:#{user_id}", "logout", %{})
    :ok
  end
end
