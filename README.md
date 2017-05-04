# Nerves.Firmware.HTTP

HTTP/REST micro service providing over-the-network firmware management.

Starts a small cowboy instance that returns status about the
current firmware, and accepts updates to the firmware via a REST-style interface.

See also [nerves_firmware](https://github.com/nerves-project/nerves_firmware), the library
on which this module depends.

## Installation/Usage

Not yet published in hex, so:

  1. Add nerves_firmware to your list of dependencies in `mix.exs`:

        def deps do
          [{:nerves_firmware_http, github: "nerves-project/nerves_firmware_http"}]
        end

  2. Ensure nerves_firmware is started before your application:

        def application do
          [applications: [:nerves_firmware_http]]
        end

That's all.  Your firmware is now queriable and updatable over the network.

## Configuration

## Configuration
In your app's config.exs, you can change a number of the default settings
by setting keys on the `nerves_frirmware_http` application:

| key          | default              | comments                            |
|--------------|----------------------|-------------------------------------|
| :port   | 8988                 |                                     |
| :path   | "/firmware"          |                                     |
| :stage_file | "/tmp/uploaded.fw"   | Firmware will be uploaded here before install, and deleted afterward |
| :json_provider | JSX          |
| :json_opts     | []           |
| :timeout       | 120000       |

So, for instance, in your config.exs, you might do:

      config :nerves_firmware_http, port: 9999,
                                    path: "/services/firmware",
                                    stage_file: "/my_tmp/new.fw"
                                    json_provider: Poison,
                                    json_opts: [space: 1, indent: 2]
                                    timeout: 240_000


### Some `CURL`ing excercises

Getting Firmware Info:

    curl "http://my_ip:8988/firmware"

Updating Firmware and Reboot:

    curl -T my_firmware.fw "http://my_ip:8988/firmware" -H "Content-Type: application/x-firmware" -H "X-Reboot: true"
