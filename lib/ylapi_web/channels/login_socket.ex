defmodule YlapiWeb.LoginSocket do
  use Phoenix.Socket

  channel "login:sync", YlapiWeb.LoginSyncChannel

  def connect(%{"token" => jwt} = _params, socket, _connect_info) do
    case YlapiWeb.Token.verify(jwt) do
      {:ok, user_id} ->
        {:ok, assign(socket, :user_id, user_id)}
      _ ->
        :error
    end
  end

  def id(_socket), do: nil
end
