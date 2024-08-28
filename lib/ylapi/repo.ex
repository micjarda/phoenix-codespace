defmodule Ylapi.Repo do
  use Ecto.Repo,
    otp_app: :ylapi,
    adapter: Ecto.Adapters.Postgres
end
