defmodule Ndm.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Ndm.Repo,
      # Start the Telemetry supervisor
      NdmWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Ndm.PubSub},
      # Start the Endpoint (http/https)
      NdmWeb.Endpoint,
      # Start a worker by calling: Ndm.Worker.start_link(arg)
      # {Ndm.Worker, arg}
      {Registry, keys: :unique, name: Ndm.CookieJarRegistry},
      {DynamicSupervisor, strategy: :one_for_one, name: Ndm.CookieJarSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ndm.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    NdmWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
