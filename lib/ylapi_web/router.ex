defmodule YlapiWeb.Router do
  use YlapiWeb, :router

  import YlapiWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {YlapiWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  pipeline :api_auth do
    plug YlapiWeb.AuthPipeline
  end

  # 🔒 AUTHENTICATION ROUTES
scope "/", YlapiWeb do
  pipe_through [:browser, :redirect_if_user_is_authenticated]

  live_session :redirect_if_user_is_authenticated,
    on_mount: [{YlapiWeb.UserAuth, :redirect_if_user_is_authenticated}] do

    live "/", UserLoginLive
    live "/users/log_in", UserLoginLive  # 👈 Přidat sem
    live "/users/register", UserRegistrationLive, :new
    live "/users/reset_password", UserForgotPasswordLive, :new
    live "/users/reset_password/:token", UserResetPasswordLive, :edit
  end

  post "/users/log_in", UserSessionController, :create
end


  # 🔒 PROTECTED LIVE ROUTES
  scope "/", YlapiWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{YlapiWeb.UserAuth, :ensure_authenticated}] do
      live "/dashboard", DashboardOverviewLive
      live "/dashboard/tokens", TokenDashboardLive
      live "/dashboard/profile", UserDashboardLive
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end

    get "/dashboard/apps", AppController, :index
    get "/dashboard/apps/:id", AppController, :show

    resources "/tasks", TaskController
  end

  # 🔒 LOGOUT ROUTE
  scope "/", YlapiWeb do
    pipe_through [:browser]
    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{YlapiWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  # 🔒 AUTHENTICATED API ROUTES
  scope "/users/api", YlapiWeb do
    pipe_through [:browser, :require_authenticated_user]
    get "/tokens", TokenController, :index
    get "/tokens/:id/revoke", TokenController, :revoke
  end

  # 🔒 API LOGIN + REGISTER
  scope "/api", YlapiWeb do
    pipe_through [:api]
    post "/login", SessionController, :create
  end

  scope "/api/auth", YlapiWeb do
    pipe_through :api
    post "/register", ApiAuthController, :register
    post "/login", ApiAuthController, :login
    post "/logout", ApiAuthController, :logout
  end

  scope "/api/auth", YlapiWeb do
    pipe_through [:api_auth]
    get "/me", ApiUserController, :me
  end

  scope "/api", YlapiWeb do
    pipe_through :api_auth
    post "/agent/logs", AgentLogController, :create
  end

  # 🔧 DEVELOPMENT TOOLS
  if Application.compile_env(:ylapi, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: YlapiWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
