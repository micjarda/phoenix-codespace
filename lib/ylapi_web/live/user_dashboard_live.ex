defmodule YlapiWeb.UserDashboardLive do
  use YlapiWeb, :live_view

  alias Ylapi.Accounts

  def mount(_params, _session, socket) do
    current_user = socket.assigns[:current_user]

    recent_tokens =
      if current_user,
        do: get_recent_tokens(current_user.id),
        else: []

    send(self(), :trigger_login_event)

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:page_title, "Uživatelský dashboard")
     |> assign(:recent_tokens, recent_tokens)
     |> assign(:breadcrumbs, [
       {"Dashboard", "/dashboard"},
       {"Profil", "/dashboard/profile"}
     ])}
  end

  def render(assigns) do
    ~H"""
    <div id="login-sync" phx-hook="LoginSync" class="p-6">
      <h1 class="text-2xl text-green-600 font-bold mb-4">
        Vítej zpět, <%= @current_user && @current_user.email || "uživateli" %>!
      </h1>

      <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
        <div class="bg-white rounded-2xl shadow p-4">
          <h2 class="text-lg font-semibold">Tvoje API tokeny</h2>
          <ul class="bg-lime-50 text-green-600 border-2 border-black rounded-lg p-1 inset-shadow-sm">
            <%= for token <- @recent_tokens do %>
              <li class="mt-2">
                <div class="flex justify-between items-center">
                  <span><%= token.app_name %></span>
                  <span class="text-sm text-gray-500">
                    expiruje: <%= format_datetime(token.expires_at) %>
                  </span>
                </div>
              </li>
            <% end %>
          </ul>
        </div>

        <div class="bg-white rounded-2xl shadow p-4">
          <h2 class="text-lg font-semibold">Nastavení účtu</h2>
          <p class="text-sm text-gray-600 mt-2">Změň si heslo, email nebo přezdívku.</p>
          <.link navigate="/users/settings" class="text-blue-600 hover:underline">
            Otevřít nastavení
          </.link>
        </div>

        <div class="bg-white rounded-2xl shadow p-4">
          <h2 class="text-lg font-semibold">Přehled aplikací</h2>
          <p class="text-sm text-gray-600 mt-2">Zobraz si připojené aplikace nebo vytvoř novou.</p>
          <.link navigate="/dashboard/apps" class="text-blue-600 hover:underline">
            Správa aplikací
          </.link>
        </div>
      </div>
    </div>
    """
  end

  def handle_info(:trigger_login_event, socket) do
    IO.puts("📡 pushing phx:logged_in event to client...")
    {:noreply, push_event(socket, "phx:logged_in", %{})}
  end

  defp get_recent_tokens(user_id) do
    Accounts.list_active_tokens_for_user(user_id)
  end

  defp format_datetime(nil), do: "-"
  defp format_datetime(datetime), do: Calendar.strftime(datetime, "%d.%m.%Y %H:%M")
end
