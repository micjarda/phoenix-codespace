defmodule YlapiWeb.UserLoginLive do
  use YlapiWeb, :live_view

  def render(assigns) do
    ~H"""
    <div id="login-sync" phx-hook="LoginSync" class="mx-auto max-w-sm">
      <.header class="text-center">
        Log in to account
        <:subtitle>
          Don't have an account?
          <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
            Sign up
          </.link>
          for an account now.
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
          <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with="Logging in..." class="w-full">
            Log in <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")

    socket =
      if socket.assigns[:current_user] do
        token = session["user_token"] || ""
        send(self(), :trigger_login_event)
        assign(socket, user_token: token)
      else
        assign(socket, user_token: nil)
      end

    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end

  def handle_info(:trigger_login_event, socket) do
    IO.puts("📡 pushing phx:logged_in event to client...")
    {:noreply, push_event(socket, "phx:logged_in", %{})}
  end
end
