defmodule YlapiWeb.InfoCard do
  use Phoenix.Component

  attr :app_name, :string, required: true
  attr :token, :string, required: true
  attr :expires_at, :string, required: true
  attr :on_revoke, :any, required: true
  attr :token_id, :integer, required: true  # ✅ Přidáváme token_id

  def info_card(assigns) do
    ~H"""
    <div class="bg-gray-100 text-white p-4 rounded-2xl shadow-lg w-full sm:w-70">
      <div class="flex items-center space-x-3">
        <div class="bg-emerald-400 p-2 rounded-full">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-white" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M10 3a4 4 0 1 0 0 8 4 4 0 1 0 0-8zM2 17a8 8 0 1 1 16 0H2z" clip-rule="evenodd"/>
          </svg>
        </div>
        <div class="text-lg font-semibold text-black"><%= @app_name %></div>
      </div>

      <div class="mt-4">
        <label class="text-gray-400 text-sm">Token</label>
        <div class="flex items-center bg-gray-300 rounded-lg p-2">
          <span id={"token-#{@app_name}"} class="flex-grow truncate"><%= @token %></span>
          <button class="ml-2 text-gray-400 hover:text-white" phx-click="copy" phx-value-token={@token}>
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <rect x="9" y="9" width="13" height="13" rx="2" ry="2"/>
              <path d="M9 3h10a2 2 0 0 1 2 2v10"/>
            </svg>
          </button>
        </div>
      </div>

      <div class="mt-4">
        <label class="text-gray-400 text-sm">Expirace</label>
        <div class="bg-gray-300 rounded-lg p-2 text-gray-700">
          <%= @expires_at %>
        </div>
      </div>

      <div class="mt-4">
        <button class="w-full bg-red-400 hover:bg-red-500 text-white p-2 rounded-lg"
                phx-click={@on_revoke}
                phx-value-token_id={@token_id}>
          Revoke
        </button>
      </div>
    </div>
    """
  end
end
