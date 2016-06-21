-- file : init.lua

state = {}

app = require("application")

file.open("config.json")
configJson = file.readline()
file.close()
ok, config = pcall(cjson.decode,configJson)
if ok then
    print( "Got config " .. configJson );
	require("wifisetup").start()
else
    print( "BAD config ");
	require("wifisetup").setup_mode()
end
