defmodule Ylapi.Repo.Migrations.AddUserApiTokens do
  use Ecto.Migration

  def change do
    create table(:user_api_tokens) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :token, :string, null: false
      add :expires_at, :utc_datetime
      add :revoked_at, :utc_datetime

      timestamps()
    end

    create unique_index(:user_api_tokens, [:token])
  end
end
