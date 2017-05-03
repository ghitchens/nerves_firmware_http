defmodule Nerves.Firmware.HTTP.Application do
  use Application
  @moduledoc false
  
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    opts = Application.get_all_env(:nerves_firmware_http)
    # Define workers and child supervisors to be supervised
    children = [
      worker(Nerves.Firmware.HTTP.Router, [opts]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Nerves.Firmware.HTTP.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
