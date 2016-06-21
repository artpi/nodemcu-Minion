-- file : config.lua
local module = {}

module.SSID = {}  
module.SSID[""] = ""

module.HOST = ""
module.PORT = 1883
module.ID = node.chipid()

module.ENDPOINT = "iot/"  
return module
