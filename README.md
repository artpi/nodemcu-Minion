# nodemcu-Minion

ESP8266 is kind of WiFi-enabled Arduino. For $4 you have a web-connected IOT machine.

nodemcu-Minion is a Plug&amp;Play ESP8266 firmware with REST API for setup.
Just start - the device will start an access point you can connect to write settings.

The idea is that most of the use-cases of iot devices are very similar.
This is intended to provide plug & play headstart on almost every project.


## Features

- Out of the box easy configuration
- MQTT / REST communication protocol
- Can act as RGB control module
- Can act as relay switch


## Quick setup

1. Build firmware you will need here: http://nodemcu-build.com/
2. Install drivers for your microcontroller and flash the firmware ( [Here is information for Wemoc D1 Mini](http://www.wemos.cc/tutorial/get_started_in_nodemcu.html) )
3. Write ./src dir of this project to your device ( [Esplorer works well for me](http://esp8266.ru/esplorer/) )
4. Restart Device
5. Connect to `ESP_` wifi network
6. Set up new config: `curl -X POST -d '{"action":"set-config","config":{...}' http://192.168.4.1/ --verbose`
7. Restart
8. Connect your hardware
9. Profit

### Config

Config has following keys:
- `"SSID"` - array of network name - password values, Ex: `"SSID":{"network-name":"password"}`
- `"connection"` - { mqtt | http } - connection protocol to be used
- `"mqtt_addr"` - IP / url of your mqtt broker
- `"mqtt_port"` - Port of your mqtt connection


### Communication

nodemcu-Minion has following commands:

- `{"action":"set", "state": { ...new state }}` - sets a state
- `{"action":"set-config", "config": { ...new config }}` - sets config
- `{"action":"get-config"}` - gets config (only on http mode)

#### HTTP

In **http** mode, it replies to every request with current state / settings.

#### MQTT

- Broadcasts current state and `id` on `iot/heartbeat` topic
- Every action requires `id` param
- Listens on `iot/things/id` topic

### Security

**None** whatsoever. This has wifi capability and I have made no effort to make it secure. Proceed with caution. Or better yet, implement some security and make a pull request.


### Roadmap

1. Create downloadable firmware to upload to device with this project baked in
2. Create an Web UI that will connect to the newly set device and provide an easy interface to generate a config.
  - Such interface could be hosted at Github Pages in this project.
  - You would load the page, connect to device acces point and set it up.
