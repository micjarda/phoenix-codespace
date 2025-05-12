defmodule YlapiWeb.DashboardOverviewLive do
  use YlapiWeb, :live_view
  alias Ylapi.Accounts
  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_user.id
    tokens = Accounts.list_user_api_tokens(user_id)

    just_logged_in = Phoenix.Flash.get(socket.assigns.flash, :just_logged_in) == "true"

    socket =
      socket
      |> assign(:page_title, "Dashboard")
      |> assign(:tokens, tokens)
      |> assign(:just_logged_in, just_logged_in)

    if connected?(socket) and just_logged_in do
      send(self(), :push_login_sync)
    end

    {:ok, socket}
  end

  def handle_info(:push_login_sync, socket) do
    IO.puts("📡 Sending phx:logged_in event to trigger localStorage login sync...")
    {:noreply, push_event(socket, "phx:logged_in", %{})}
  end

  def render(assigns) do
    ~H"""
    <div id="login-sync" phx-hook="LoginSync" class="space-y-6 p-6">
      <h1 class="text-3xl font-bold text-green-600">Přehled</h1>

      <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
        <div class="bg-white rounded-xl shadow p-4">
          <h2 class="text-xl font-semibold mb-2">Počet tokenů</h2>
          <p class="text-4xl text-green-500"><%= length(@tokens) %></p>
        </div>

        <div class="bg-white rounded-xl shadow p-4">
          <h2 class="text-xl font-semibold mb-2">Správa aplikací</h2>
          <.link navigate="/dashboard/apps" class="text-blue-600 hover:underline">Zobrazit aplikace</.link>
        </div>

        <div class="bg-white rounded-xl shadow p-4">
          <h2 class="text-xl font-semibold mb-2">Uživatelský profil</h2>
          <.link navigate="/dashboard/profile" class="text-blue-600 hover:underline">Zobrazit profil</.link>
        </div>
      </div>
    </div>
    """
  end
end
