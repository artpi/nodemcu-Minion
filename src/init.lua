-- file : init.lua

file.open("config.json");
configJson = file.readline();
file.close();
wifisetup = require("wifi-setup");
app_handler = require("application");
ok, config = pcall(cjson.decode,configJson);
if ok then
    print( "Got config " .. configJson );
    if config.connection == "mqtt" and config.mqtt_addr ~= nil and config.mqtt_port ~= nil then
    	app_handler.setup();
		wifisetup.start( require("mqtt-connection"), app_handler );
	elseif config.connection == "http" then
		app_handler.setup();
		wifisetup.start( require("http-connection"), app_handler );
	else
		wifisetup.setup_mode();
	end
else
    print( "BAD config ");
	wifisetup.setup_mode();
end
