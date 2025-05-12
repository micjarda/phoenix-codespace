defmodule YlapiWeb.LoginSyncChannel do
  use Phoenix.Channel

  require Logger

  def join("login:sync", _params, socket) do
    Logger.debug("[LoginSyncChannel] Joined by user_id=#{inspect(socket.assigns[:user_id])}")
    {:ok, socket}
  end

  def handle_in("login_event", %{"stamp" => stamp}, socket) do
    Logger.debug("[LoginSyncChannel] Received login_event from user_id=#{inspect(socket.assigns[:user_id])} with stamp=#{stamp}")

    broadcast_from!(socket, "sync_login", %{
      user_id: socket.assigns[:user_id],
      stamp: stamp
    })

    {:noreply, socket}
  end
end
