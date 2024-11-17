defmodule Ylapi.Repo.Migrations.AddAppNameToUserApiTokens do
  use Ecto.Migration

  def change do
    alter table(:user_api_tokens) do
      add :app_name, :string
    end
  end
end
