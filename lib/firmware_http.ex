defmodule Nerves.Firmware.HTTP do

  @moduledoc """
  HTTP/JSON microservice to query and update firmware on a Nerves device.

  Defines an _acceptor_ that receives and installs firmware updates. Simply use
  use __HTTP PUT__ to send a firmware to the URI for the device, specifying
  Content-Type `application/x-firmware`

  Also defines a _provider_ for the `application/json` content type that allows
  an HTTP GET to reutrn information on the current firmware status and metadata
  in JSON form.

  ## Configuration
  In your app's config.exs, you can change a number of the default settings
  by setting keys on the `nerves_frirmware_http` application:

  | key          | default              | comments                            |
  |--------------|----------------------|-------------------------------------|
  | :port   | 8988                 |                                     |
  | :path   | "/firmware"          |                                     |
  | :stage_file | "/tmp/uploaded.fw"   | Firmware will be uploaded here before install, and deleted afterward |

  So, for instance, in your config.exs, you might do:

        config :nerves_firmware_http, port: 9999,
                                      path: "/services/firmware",
                                      stage_file: "/my_tmp/new.fw"
  """
  @http_port Application.get_env(:nerves_firmware_http, :port, 8988)
  @http_path Application.get_env(:nerves_firmware_http, :path, "/firmware")

  @doc "Application start callback"
  @spec start(atom, term) :: {:ok, pid} | {:error, String.t}
  def start(_type, _args) do
    dispatch = :cowboy_router.compile [{:_,[{@http_path, Nerves.Firmware.HTTP.Transport, []}]}]
    :cowboy.start_http(__MODULE__, 10, [port: @http_port], [env: [dispatch: dispatch]])
  end
end