defmodule Ylapi.AgentLogs do
  import Ecto.Query, warn: false
  alias Ylapi.Repo
  alias Ylapi.AgentLogs.AgentLog

  def create_log(attrs) do
    %AgentLog{}
    |> AgentLog.changeset(attrs)
    |> Repo.insert()
  end
end
