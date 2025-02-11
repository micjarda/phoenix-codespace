defmodule YlapiWeb.TokenDashboardLive do
  use Phoenix.LiveView
  import YlapiWeb.TokenDashboardRenderer

  alias Ylapi.Repo
  alias Ylapi.Accounts.UserApiToken
  alias Phoenix.PubSub  # 👈 Přidáváme PubSub pro real-time aktualizace

  @topic "tokens"

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      PubSub.subscribe(Ylapi.PubSub, @topic)  # ✅ Přihlásíme se k tématu "tokens"
    end

    tokens = Repo.all(UserApiToken)
    {:ok, assign(socket, tokens: tokens)}
  end

  @impl true
  def handle_info({:new_token, _token_data}, socket) do
    tokens = Repo.all(UserApiToken)  # ✅ Načteme nejnovější tokeny
    {:noreply, assign(socket, tokens: tokens)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.token_dashboard_renderer tokens={@tokens} />
    """
  end
end
