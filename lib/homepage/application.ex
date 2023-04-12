defmodule Homepage.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      HomepageWeb.Telemetry,
      # Start the Ecto repository
      Homepage.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Homepage.PubSub},
      # Start Finch
      {Finch, name: Homepage.Finch},
      # Start the Endpoint (http/https)
      HomepageWeb.Endpoint
      # Start a worker by calling: Homepage.Worker.start_link(arg)
      # {Homepage.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Homepage.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HomepageWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
