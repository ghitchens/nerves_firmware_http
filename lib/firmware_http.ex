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

  | key            | default            | comments                                                             |
  |----------------|--------------------|----------------------------------------------------------------------|
  | :port          | 8988               |                                                                      |
  | :path          | "/firmware"        |                                                                      |
  | :json_provider | JSX                |                                                                      |
  | :json_opts     | []                 |                                                                      |
  | :timeout       | 120000             |                                                                      |

  So, for instance, in your config.exs, you might do:

        config :nerves_firmware_http, port: 9999,
                                      path: "/services/firmware",
                                      json_provider: Poison,
                                      json_opts: [space: 1, indent: 2],
                                      timeout: 240_000
  """

end
