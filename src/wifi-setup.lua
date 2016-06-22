-- file : wifisetup.lua

local module = {};
local attempts = 0;
local app = nil;
local connection_protocol = nil;

local function setup_mode()
  print("Entering setup mode, turnong on led");
  gpio.mode(4,gpio.OUTPUT);
  gpio.write(4,gpio.LOW);
  wifi.setmode(wifi.SOFTAP);
  require("http-connection").start( nil );
end

local function wifi_wait_ip()  
  if wifi.sta.getip()== nil then
    print("IP unavailable, Waiting...");
    attemts = attempts + 1;
    if attempts > 10 then
      tmr.stop(1);
      setup_mode();
    end
  else
    tmr.stop(1)
    print("\n====================================");
    print("ESP8266 mode is: " .. wifi.getmode());
    print("MAC address is: " .. wifi.ap.getmac());
    print("IP is "..wifi.sta.getip());
    print("====================================");
    if module.connection ~= nil and module.connection.start ~= nil then
      module.connection.start( app );
    end
  end
end

local function wifi_start(list_aps)
    print("Got acces points");
    tmr.stop(2)
    if list_aps then
        unknownNetwork = true
        for key,value in pairs(list_aps) do
            if config.SSID and config.SSID[key] then
                unknownNetwork = false
                wifi.setmode(wifi.STATION);
                wifi.sta.config(key,config.SSID[key]);
                wifi.sta.connect();
                print("Connecting to " .. key .. " ...");
                --config.SSID = nil  -- can save memory
                tmr.alarm(1, 2500, 1, wifi_wait_ip);
            end
        end

        if unknownNetwork then
          setup_mode();
        end
    else
        print("Error getting AP list");
    end
end

function get_access_points()
  print("Configuring Wifi ...");
  wifi.setmode(wifi.STATION);
  print("GetAp");
  wifi.sta.getap(wifi_start);
end

function module.start( connection_handler, application )
  app = application;
  module.connection = connection_handler;
  get_access_points()
  tmr.alarm(2, 5000, 1, get_access_points);
end

function module.setup_mode()
    setup_mode();
end

return module
