defmodule YlapiWeb.UserSessionController do
  use YlapiWeb, :controller

  alias Ylapi.Accounts
  alias YlapiWeb.UserAuth

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "Account created successfully!")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:user_return_to, ~p"/users/settings")
    |> create(params, "Password updated successfully!")
  end

  def create(conn, %{"user" => %{"email" => email, "password" => password}} = params, info \\ "Welcome back!") do
    case Accounts.get_user_by_email_and_password(email, password) do
      nil ->
        conn
        |> put_flash(:error, "Invalid email or password")
        |> put_flash(:email, String.slice(email, 0, 160))
        |> redirect(to: ~p"/users/log_in")

      user ->
        conn
        |> put_flash(:info, info)
        |> put_session(:just_logged_in, true) # ✅ pro cross-tab login sync
        |> UserAuth.log_in_user(user, params["user"])
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
