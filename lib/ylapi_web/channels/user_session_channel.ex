defmodule YlapiWeb.UserSessionChannel do
  use Phoenix.Channel

  def join("user_session:" <> _user_id, _params, socket) do
    {:ok, socket}
  end
end
