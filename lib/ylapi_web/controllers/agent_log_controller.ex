defmodule YlapiWeb.AgentLogController do
  use YlapiWeb, :controller
  alias Ylapi.AgentLogs

  action_fallback YlapiWeb.FallbackController

  def create(conn, %{"event" => event, "source" => source} = params) do
    metadata = Map.get(params, "metadata", %{})

    with {:ok, log} <- AgentLogs.create_log(%{
           event: event,
           source: source,
           metadata: metadata
         }) do
      conn
      |> put_status(:created)
      |> json(%{id: log.id, inserted_at: log.inserted_at})
    end
  end
end
