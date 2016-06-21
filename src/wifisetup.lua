-- file : wifisetup.lua

local module = {}

local attempts = 0

local function setup_mode()
  print("Entering setup mode, turnong on led")
  gpio.mode(4,gpio.OUTPUT)
  gpio.write(4,gpio.LOW)
  wifi.setmode(wifi.SOFTAP)
  require("http").start()
end

local function wifi_wait_ip()  
  if wifi.sta.getip()== nil then
    print("IP unavailable, Waiting...")
    attemts = attempts + 1
    if attempts > 10 then
      tmr.stop(1)
      setup_mode()
    end
  else
    tmr.stop(1)
    print("\n====================================")
    print("ESP8266 mode is: " .. wifi.getmode())
    print("MAC address is: " .. wifi.ap.getmac())
    print("IP is "..wifi.sta.getip())
    print("====================================")
    app.start()
  end
end

local function wifi_start(list_aps)  
    if list_aps then
        unknownNetwork = false
        for key,value in pairs(list_aps) do
            if config.SSID and config.SSID[key] then
                wifi.setmode(wifi.STATION);
                wifi.sta.config(key,config.SSID[key])
                wifi.sta.connect()
                unknownNetwork = false
                print("Connecting to " .. key .. " ...")
                --config.SSID = nil  -- can save memory
                tmr.alarm(1, 2500, 1, wifi_wait_ip)
            end
        end

        if unknownNetwork then
          setup_mode()
        end
    else
        print("Error getting AP list")
    end
end

function module.start()
  print("Configuring Wifi ...")
  wifi.setmode(wifi.STATION);
  wifi.sta.getap(wifi_start)
end

function module.setup_mode()
    setup_mode()
end

return module
