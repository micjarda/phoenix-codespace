defmodule Ylapi.Accounts.UserMetadata do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_metadata" do
    field :nickname, :string
    field :source, :string

    belongs_to :user, Ylapi.Accounts.User

    timestamps()
  end

  def changeset(metadata, attrs) do
    metadata
    |> cast(attrs, [:nickname, :source])
    |> validate_length(:nickname, max: 30)
  end
end
