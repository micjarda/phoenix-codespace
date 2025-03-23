defmodule Ylapi.AgentLogs.AgentLog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "agent_logs" do
    field :metadata, :map
    field :source, :string
    field :event, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(agent_log, attrs) do
    agent_log
    |> cast(attrs, [:event, :source, :metadata])
    |> validate_required([:event, :source])
  end
end
