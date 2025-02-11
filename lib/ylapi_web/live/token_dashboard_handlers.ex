defmodule YlapiWeb.TokenDashboardHandlers do
  use Phoenix.LiveView  # 👈 Přidali jsme LiveView

  alias Ylapi.Repo
  alias Ylapi.Accounts.UserAPIToken

  def handle_info({:new_token, _token_data}, socket) do
    tokens = Repo.all(UserAPIToken)
    {:noreply, assign(socket, tokens: tokens)}  # ✅ assign/2 už bude fungovat
  end
end
