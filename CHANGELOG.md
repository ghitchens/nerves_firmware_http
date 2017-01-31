# ChangeLog

## 0.3.0-dev

* Bug Fixes
  * fixed issue where response would not be sent prior to rebooting the device

* New Features
  * added mix task `firmware.push` for pushing firmware to hosts and ip's. Example: `mix firmware.push 192.168.1.100 --target rpi3`

## 0.2.0

* New Features
  * Broke out Nerves.Firmware.HTTP service from Nerves.Firmware
