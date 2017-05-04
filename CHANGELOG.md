# ChangeLog

## 0.4.0

* New Features
  * stream firmware to nerves_firmware 0.4
  * allow timeout for requests to be configurable
  * allow custom JSON library to be used as well as custom encode opts

## 0.3.2

* Bug Fixes
  * Fixed issue with --target not resolving to the proper path in nerves 0.5.x

## 0.3.1

* Bug Fixes
  * removed all compile-time configuration, all runtime now
  * elixir 1.4 clean build
  * cleanup of mix dependencies (now ref hex packages)

## 0.3.0

* Bug Fixes
  * fixed issue where response would not be sent prior to rebooting the device

* New Features
  * added mix task `firmware.push` for pushing firmware to hosts and ip's. Example: `mix firmware.push 192.168.1.100 --target rpi3`

## 0.2.0

* New Features
  * Broke out Nerves.Firmware.HTTP service from Nerves.Firmware
