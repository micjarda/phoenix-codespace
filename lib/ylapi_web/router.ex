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
  end

  pipeline :api_auth do
    plug YlapiWeb.AuthPipeline
  end

  # scope "/api", YlapiWeb do
  #   pipe_through [:api, :api_auth]

  #   post "/login", SessionController, :create

  #   get "/profile", ProfileController, :show
  # end

  scope "/api", YlapiWeb do
    pipe_through [:api]  # Pouze :api, bez :api_auth pro login

    post "/login", SessionController, :create  # Umožněte přihlášení bez ověřování tokenu
  end

  scope "/api", YlapiWeb do
    pipe_through [:api, :api_auth]  # Pro všechny chráněné cesty bude nutné mít JWT token

    get "/profile", ProfileController, :show
  end

  scope "/", YlapiWeb do
    pipe_through :browser
    # pipe_through [:browser, :require_authenticated_user]

    get "/", PageController, :home
  end

    scope "/", YlapiWeb do
    pipe_through [:browser, :require_authenticated_user]

    resources "/tasks", TaskController
  end

  # Other scopes may use custom stacks.
  # scope "/api", YlapiWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:ylapi, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: YlapiWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

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
end
