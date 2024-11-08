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
    plug :fetch_current_user  # Fetch current user from session
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug YlapiWeb.AuthPipeline  # Guardian pipeline for API authentication
  end

  # Unauthenticated API route (login)
  scope "/api", YlapiWeb do
    pipe_through [:api]
    post "/login", SessionController, :create  # Login route
  end

  # Authenticated API route
  scope "/api", YlapiWeb do
    pipe_through [:api, :api_auth]  # Requires authentication for profile
    get "/profile", ProfileController, :show  # Example authenticated route
  end

  # Public routes (accessible without authentication)
  scope "/", YlapiWeb do
    pipe_through :browser
    get "/", PageController, :home
  end

  # Protected routes (require authenticated user based on session)
  scope "/", YlapiWeb do
    pipe_through [:browser, :require_authenticated_user]  # Session-based authentication

    resources "/tasks", TaskController  # Task routes using session-based auth
    get "/tokens", TokenController, :index  # View tokens
    get "/tokens/:id/revoke", TokenController, :revoke  # Revoke token
  end

  ## Authentication routes (login, registration)
  scope "/", YlapiWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{YlapiWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", YlapiWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{YlapiWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", YlapiWeb do
    pipe_through [:browser]
    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{YlapiWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:ylapi, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: YlapiWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
