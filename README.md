# Nerves.Firmware.HTTP

An HTTP/REST microservice built on top of Nerves.Firmware

Starts a small, cowboy-based microservice that returns status about the
current firmware, and accepts updates to the firmware via a REST-style interface.

See [nerves_firmware](https://github.com/ghitchens/nerves_firmware), on which
this module depends.

## Installation/Usage

Until we publish in hex or move officially to nerves_project:

  1. Add nerves_firmware to your list of dependencies in `mix.exs`:

        def deps do
          [{:nerves_firmware, github: "ghitchens/nerves_firmware_http"}]
        end

  2. Ensure nerves_firmware is started before your application:

        def application do
          [applications: [:nerves_firmware_http]]
        end

That's all.  Your firmware is now queriable and updatable!

## Configuration

In your app's config.exs, you can change a number of the default settings
for Nerves.Firmware:

| key          | default              | comments                            |
|--------------|----------------------|-------------------------------------|
| :http_port   | 8988                 |                                     |
| :http_path   | "/firmware"          |                                     |
| :upload_path | "/tmp/uploaded.fw"   | Firmware will be uploaded here before install, and deleted afterward |

## REST API

See Nerves.Firmware.HTTP

### Some `CURL`ing excercises

Getting Firmware Info:

    curl "http://my_ip:8988/firmware"

Updating Firmware and Reboot:

    curl -T my_firmware.fw "http://my_ip:8988/firmware" -H "Content-Type: application/x-firmware" -H "X-Reboot: true"

## TODO

- [ ] finish documenting API
- [x] finish two phase updates (upgrade/finalize)
- [ ] understand :permanent app start supervision
- [x] build in auto-restart option
- [ ] import cell security model
- [ ] automatically integrate with service discovery mechanism
