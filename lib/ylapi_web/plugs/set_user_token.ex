defmodule YlapiWeb.Plugs.SetUserToken do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    if current_user = conn.assigns[:current_user] do
      token = YlapiWeb.Token.sign(current_user.id)
      assign(conn, :user_token, token)
    else
      conn
    end
  end
end
