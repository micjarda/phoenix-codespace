defmodule YlapiWeb.DashboardOverviewLive do
  use YlapiWeb, :live_view
  alias Ylapi.Accounts

  def mount(_params, session, socket) do
    user_id = socket.assigns.current_user.id
    tokens = Accounts.list_user_api_tokens(user_id)

    just_logged_in =
      Map.get(socket.assigns, :just_logged_in) ||
      Map.get(session, "just_logged_in") ||
      false

    {:ok,
     socket
     |> assign(:page_title, "Dashboard")
     |> assign(:tokens, tokens)
     |> assign(:just_logged_in, just_logged_in)}
  end

  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="space-y-6 p-6">
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
