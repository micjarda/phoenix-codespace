defmodule YlapiWeb.PageController do
  use YlapiWeb, :controller

  def home(conn, _params) do
    if conn.assigns[:current_user] do
      redirect(conn, to: ~p"/dashboard")
    else
      just_logged_in = get_session(conn, :just_logged_in) || false

      conn
      |> delete_session(:just_logged_in)
      |> assign(:just_logged_in, just_logged_in)
      |> render(:home, layout: false)
    end
  end

end
