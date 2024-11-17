defmodule Ylapi.Accounts.UserApiToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_api_tokens" do
    field :token, :string
    field :app_name, :string
    field :expires_at, :utc_datetime
    field :revoked_at, :utc_datetime
    belongs_to :user, Ylapi.Accounts.User

    timestamps()
  end

  def changeset(token, attrs) do
    token
    |> cast(attrs, [:token, :app_name, :expires_at, :revoked_at, :user_id])
    |> validate_required([:token, :app_name, :expires_at, :user_id])
  end
end
