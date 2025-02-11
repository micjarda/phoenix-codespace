defmodule YlapiWeb.TokenDashboardLive do
  use Phoenix.LiveView
  import Ecto.Query  # ✅ Nutné pro `from/2`
  import YlapiWeb.TokenDashboardRenderer
  import YlapiWeb.InfoCard

  alias Ylapi.Repo
  alias Ylapi.Accounts.UserApiToken
  alias Phoenix.PubSub

  @topic "tokens"

  @impl true
  def mount(_params, session, socket) do
    user_id = session["user_id"]
    user = Repo.get(Ylapi.Accounts.User, user_id)

    tokens = Repo.all(from t in UserApiToken, where: is_nil(t.revoked_at))  # ✅ Pouze aktivní tokeny

    if connected?(socket), do: PubSub.subscribe(Ylapi.PubSub, @topic)  # ✅ Přihlášení k PubSub

    {:ok, assign(socket, tokens: tokens, current_user: user)}
  end

  @impl true
  def handle_info({:token_revoked, token_id}, socket) do
    new_tokens = Enum.filter(socket.assigns.tokens, fn t -> t.id != token_id end)  # ✅ Odebrání tokenu
    {:noreply, assign(socket, tokens: new_tokens)}
  end

  @impl true
  def handle_event("revoke_token", %{"token_id" => token_id_str}, socket) do
    user = socket.assigns.current_user  # Přihlášený uživatel
    token_id = String.to_integer(token_id_str)  # Převod token_id na číslo

    case Ylapi.Accounts.revoke_api_token(user, token_id) do
      {:ok, _} ->
        PubSub.broadcast(Ylapi.PubSub, @topic, {:token_revoked, token_id})  # ✅ Publikování změny
        {:noreply, socket}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
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
