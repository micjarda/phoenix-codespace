defmodule YlapiWeb.AuthPipeline do
  use Guardian.Plug.Pipeline, otp_app: :ylapi,
    module: Ylapi.Guardian,
    error_handler: YlapiWeb.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
