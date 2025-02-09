defmodule YlapiWeb.TokenDashboardLive do
  use YlapiWeb, :live_view

  alias Ylapi.Accounts
  alias Phoenix.PubSub

  @impl true
  def mount(_params, %{"user_id" => user_id} = _session, socket) do
    if connected?(socket) do
      # Přihlášení k odběru kanálu
      PubSub.subscribe(Ylapi.PubSub, "user_tokens:#{user_id}")
    end

    tokens = Accounts.list_user_api_tokens(user_id)
    {:ok, assign(socket, tokens: tokens, user_id: user_id)}
  end

  @impl true
  def handle_info({:new_token, token_data}, socket) do
    # Přidání nového tokenu do seznamu
    new_tokens = [token_data | socket.assigns.tokens]
    {:noreply, assign(socket, tokens: new_tokens)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1>Token Dashboard</h1>
      <ul>
        <%= for token <- @tokens do %>
          <li>
            <strong>ID:</strong> <%= token.id %> <br>
            <strong>Token:</strong> <%= token.token %> <br>
            <strong>App Name:</strong> <%= token.app_name %>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end
end
