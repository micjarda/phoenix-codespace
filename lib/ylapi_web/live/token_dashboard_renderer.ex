defmodule YlapiWeb.TokenDashboardRenderer do
  use Phoenix.Component

  attr :tokens, :list, required: true  # Definujeme atribut tokens

  def token_dashboard_renderer(assigns) do
    ~H"""
    <div>
      <h1 class="bg-emerald-200 mb-10 p-5 text-left rounded-b-lg">
        List of your tokens
      </h1>
      <ul>
        <%= for token <- @tokens do %>
          <li class="bg-gray-100 m-5 p-5 text-center rounded-sm">
            <strong>App Name:</strong> <%= token.app_name %>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end
end
