defmodule Nerves.Firmware.HTTP.Application do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # worker(Nerves.Firmware.HTTP.Worker, [arg1, arg2, arg3])
      worker(Task, [fn -> init() end], restart: :transient)
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Nerves.Firmware.HTTP.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def init do
    port = Application.get_env(:nerves_firmware_http, :port, 8988)
    path = Application.get_env(:nerves_firmware_http, :path, "/firmware")
    timeout = Application.get_env(:nerves_firmware_http, :timeout, 120_000)
    dispatch = :cowboy_router.compile [{:_,[{path, Nerves.Firmware.HTTP.Transport, []}]}]
    :cowboy.start_http(__MODULE__, 10, [port: port], [env: [dispatch: dispatch], timeout: timeout])
  end

end
