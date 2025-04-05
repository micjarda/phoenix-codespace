defmodule YlapiWeb.TokenDashboardLive do
  use Phoenix.LiveView

  import Ecto.Query
  import YlapiWeb.InfoCard
  alias Ylapi.Repo
  alias Ylapi.Accounts.UserApiToken
  alias Phoenix.PubSub

  @topic "tokens"

  @impl true
  @spec mount(any(), nil | maybe_improper_list() | map(), Phoenix.LiveView.Socket.t()) ::
          {:ok, any()}
  def mount(_params, session, socket) do
    user_id = session["user_id"]
    user = Repo.get(Ylapi.Accounts.User, user_id)

    tokens = Repo.all(from t in UserApiToken, where: is_nil(t.revoked_at))  # ✅ Pouze aktivní tokeny

    if connected?(socket), do: PubSub.subscribe(Ylapi.PubSub, @topic)

    {:ok, assign(socket, tokens: tokens, current_user: user)}
  end

  @impl true
  def handle_info({:new_token, _token_data}, socket) do
    tokens = Repo.all(from t in UserApiToken, where: is_nil(t.revoked_at))  # ✅ Načítání pouze aktivních tokenů
    {:noreply, assign(socket, tokens: tokens)}
  end

  @impl true
  def handle_event("copy", %{"token" => token}, socket) do
    {:noreply, push_event(socket, "clipboard:copy", %{text: token})}
  end

  @impl true
  def handle_event("revoke_token", %{"token_id" => token_id_str}, socket) do
    user = socket.assigns.current_user
    token_id = String.to_integer(token_id_str)

    case Ylapi.Accounts.revoke_api_token(user, token_id) do
      {:ok, _} ->
        tokens = Repo.all(from t in UserApiToken, where: is_nil(t.revoked_at))
        {:noreply, assign(socket, tokens: tokens)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h1 class="text-center text-stone-50 bg-green-500 text-5xl rounded-xl m-5 p-2 font-mono">Tokens</h1>
    <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4 p-4">
      <%= for token <- @tokens do %>
        <.info_card
          app_name={token.app_name}
          token={token.token}
          expires_at={token.expires_at}
          on_revoke="revoke_token"
          token_id={token.id}
        />
      <% end %>
    </div>
    """
  end
end
