defmodule YlapiWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "user_session:*", YlapiWeb.UserSessionChannel  # <- Přidej TOTO!!

  def connect(%{"token" => token}, socket, _connect_info) do
    case Ylapi.Accounts.get_user_id_from_token(token) do
      nil ->
        :error

      user_id when is_integer(user_id) ->
        {:ok, assign(socket, :user_id, user_id)}
    end
  end

  def connect(_, _, _), do: :error

  def id(socket), do: "user_socket:#{socket.assigns.user_id}"
end
