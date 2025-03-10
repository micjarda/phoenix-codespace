defmodule YlapiWeb.Components.CopyableInput do
  use Phoenix.Component

  attr :label, :string, required: true
  attr :value, :string, required: true

  def render(assigns) do
    ~H"""
    <div class="copyable-input">
      <label><%= @label %></label>
      <div class="input-wrapper">
        <input type="text" readonly value={@value} id={"copy-input-#{@value}"} class="copy-input">
        <button
          id={"copy-btn-#{@value}"}
          phx-hook="Clipboard"
          phx-value-target={"copy-input-#{@value}"}  # ✅ Opravené předání správného ID
          class="copy-button"
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
            <path d="M6 2h9v2H8v11H6V2zm3 4h9v14H9V6zm-4 4h2v10H5V10z" fill="currentColor"/>
          </svg>
        </button>
      </div>
    </div>
    """
  end
end
