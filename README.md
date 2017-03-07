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

In your app's config.exs, you can change a number of the default settings
for Nerves.Firmware.HTTP:

| key          | default            | comments                                    |
|--------------|--------------------|---------------------------------------------|
| :port        | 8988               | port on which http is served                |
| :path        | "/firmware"        | http path at which services are offered     |
| :upload_path | "/tmp/uploaded.fw" | Firmware upload staging area                |
| :tls         | false              | If true, use HTTP over TLS                  |
| :ca_cert     | /tls/ca.crt        | Path of TLS certificate authority .crt file |
| :dev_cert    | /tls/device.crt    | Path of TLS device .crt file                |
| :dev_key     | /tls/device.key    | Path of TLS private key (.key) file         |
| :auth        | none               | See auth section for usage                  |
| :auth_realm  | "Nerves FIrmware"  | Authentication realm (for HTTP)              |

## Security and Authentication 

Nerves.Firmware.HTTP provides a few different security models.

### Values for HTTP AUTH

:none - No authentication/authorization required (open API)
:deny - Deny all requests (disable API)
{:pwlist, [...]} - A keyword list of usernames and passwords
{:authorized_keys, authkeyfile}

## Some `CURL`ing excercises

Getting Firmware Info:

    curl "http://my_ip:8988/firmware"

Updating Firmware and Reboot:

    curl -T my_firmware.fw "http://my_ip:8988/firmware" -H "Content-Type: application/x-firmware" -H "X-Reboot: true"

