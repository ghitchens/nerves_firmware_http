# Nerves.Firmware.HTTP

HTTP/REST micro service providing over-the-network firmware management.

Starts a small cowboy instance that returns status about the
current firmware, and accepts updates to the firmware via a REST-style interface.

See also [nerves_firmware](https://github.com/nerves-project/nerves_firmware), the library
on which this module depends.

## Installation/Usage

Add nerves_firmware to your list of dependencies in `mix.exs` and a json library,
by default you can use exjsx:
```elixir
  def deps do
    [{:nerves_firmware_http, "~> 0.4"},
     {:exjsx, "~> 4.0"}]
  end
```

### Using a Different JSON Provider

To use a different JSON provider, simply specify one in your deps:
```elixir
  def deps do
    [{:nerves_firmware_http, "~> 0.4"},
     {:poison, "~> 3.1"}]
  end
```
And pass the module in your config

```elixir
  config :nerves_firmware_http,
    json_provider: Poison,
    json_opts: []
```


That's all. Your firmware is now queriable and updatable over the network.

## Configuration
In your app's config.exs, you can change a number of the default settings
by setting keys on the `nerves_frirmware_http` application:

| key            | default              |
|----------------|----------------------|
| :port          | 8988                 |
| :path          | "/firmware"          |
| :json_provider | JSX                  |
| :json_opts     | []                   |
| :timeout       | 120000               |

So, for instance, in your config.exs, you might do:

```elixir
  config :nerves_firmware_http,
    port: 9999,
    path: "/services/firmware",
    json_provider: Poison,
    json_opts: [space: 1, indent: 2]
    timeout: 240_000
```
## Using Firmware.Push

You can stream the .fw files over the network to a device by using the nerves_firmware_http package. You can specify a .fw file directly, or let mix figure it our for you based on your target.

`mix firmware.push 192.168.1.100 --target rpi0`

### Some `CURL`ing excercises

Getting Firmware Info:

    curl "http://my_ip:8988/firmware"

Updating Firmware and Reboot:

    curl -T my_firmware.fw "http://my_ip:8988/firmware" -H "Content-Type: application/x-firmware" -H "X-Reboot: true"
