defmodule Ylapi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      YlapiWeb.Telemetry,
      Ylapi.Repo,
      {Redix, name: :redix, host: "100.100.33.21", port: 6379},
      {DNSCluster, query: Application.get_env(:ylapi, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub,
        name: Ylapi.PubSub,
        adapter: Phoenix.PubSub.Redis,
        host: "100.100.33.21",
        port: 6379,
        node_name: "ylapi@localhost"
      },
      {Finch, name: Ylapi.Finch},
      YlapiWeb.Endpoint
    ]
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ylapi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    YlapiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
