defmodule Ylapi.Accounts.UserApiToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_api_tokens" do
    field :token, :string
    field :expires_at, :utc_datetime
    field :revoked_at, :utc_datetime
    belongs_to :user, Ylapi.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(token, attrs) do
    token
    |> cast(attrs, [:token, :expires_at, :revoked_at, :user_id])
    |> validate_required([:token, :expires_at, :user_id])
    |> unique_constraint(:token)
  end
end
