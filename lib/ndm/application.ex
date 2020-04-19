defmodule Ndm.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(NdmWeb.Endpoint, []),
      # Start your own worker by calling: Ndm.Worker.start_link(arg1, arg2, arg3)
      # worker(Ndm.Worker, [arg1, arg2, arg3]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ndm.Supervisor]
    Ndm.SessionManager.start_link()
    Ndm.DailiesManager.start_link()
    Ndm.DailiesManager.add_daily(Ndm.Dailies.AnchorManagement, "AnchorManagement")
    Ndm.DailiesManager.add_daily(Ndm.Dailies.AppleBobbing, "AppleBobbing")
    Ndm.DailiesManager.add_daily(Ndm.Dailies.Bank, "Bank")
    Ndm.DailiesManager.add_daily(Ndm.Dailies.Fishing, "Fishing")
    Ndm.DailiesManager.add_daily(Ndm.Dailies.ForgottenShore, "ForgottenShore")
    Ndm.DailiesManager.add_daily(Ndm.Dailies.FruitMachine, "FruitMachine")
    Ndm.DailiesManager.add_daily(Ndm.Dailies.Jelly, "Jelly")
    Ndm.DailiesManager.add_daily(Ndm.Dailies.LunarTemple, "LunarTemple")
    Ndm.DailiesManager.add_daily(Ndm.Dailies.Omlette, "Omlette")
    Ndm.DailiesManager.add_daily(Ndm.Dailies.Springs, "Springs")
    Ndm.DailiesManager.add_daily(Ndm.Dailies.Tomb, "Tomb")
    Ndm.DailiesManager.add_daily(Ndm.Dailies.Tombola, "Tombola")
    Ndm.DailiesManager.add_daily(Ndm.Dailies.TDMBGPOP, "TDMBGPOP")
    #Ndm.DailiesManager.add_daily(Ndm.Dailies.WheelOfFortune, "WheelOfFortune")

    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    NdmWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
