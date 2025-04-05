defmodule Ylapi.Repo.Migrations.CreateUserMetadata do
  use Ecto.Migration

  def change do
    create table(:user_metadata) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :nickname, :string
      add :source, :string # např. "autosuki"
      timestamps()
    end

    create unique_index(:user_metadata, [:user_id])
  end
end
