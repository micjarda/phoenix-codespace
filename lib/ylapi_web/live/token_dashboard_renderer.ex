defmodule YlapiWeb.TokenDashboardRenderer do
  use Phoenix.Component

  attr :tokens, :list, required: true  # Definujeme atribut tokens

  def token_dashboard_renderer(assigns) do
    ~H"""
    <div>
      <h1>Seznam tokenů</h1>
      <ul>
        <%= for token <- @tokens do %>
          <li class="bg-gray-200 m-20">
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
