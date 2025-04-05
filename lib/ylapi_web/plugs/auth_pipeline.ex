defmodule YlapiWeb.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :ylapi,
    module: Ylapi.Guardian,
    error_handler: YlapiWeb.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
  plug :assign_current_user

  defp assign_current_user(conn, _opts) do
    case Guardian.Plug.current_resource(conn) do
      nil -> conn
      user -> assign(conn, :current_user, user)
    end
  end
end
