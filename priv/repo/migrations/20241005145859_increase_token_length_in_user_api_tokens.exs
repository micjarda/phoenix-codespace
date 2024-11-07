defmodule Ylapi.Repo.Migrations.IncreaseTokenLengthInUserApiTokens do
  use Ecto.Migration

  def change do
    alter table(:user_api_tokens) do
      modify :token, :text
    end
  end
end
