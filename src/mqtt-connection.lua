-- file : application.lua
local module = {}
local id = node.chipid()
local m = nil
local application = {}

-- Sends a simple ping to the broker
local function send_ping()  
    m:publish("iot/heartbeat",cjson.encode( application.get() ),0,0)
end

-- Sends my id to the broker for registration
local function register_myself()  
    m:subscribe( "iot/things/" .. id,0,function(conn)
        print("Successfully subscribed to data endpoint")
    end)
end

local function mqtt_start()  
    m = mqtt.Client(id, 120)
    -- register message callback beforehand
    m:on("message", function(conn, topic, data) 
      if data ~= nil then
        -- do something, we have received a message
        ok, payload = pcall(cjson.decode,data)
        if ok then
            application.run( payload )
        end
      end
    end)
    -- Connect to broker
    m:connect(config.mqtt_addr, config.mqtt_port, 0, 1, function(con) 
        register_myself()
        -- And then pings each 1000 milliseconds
        tmr.stop(6)
        tmr.alarm(6, 1000, 1, send_ping)
    end) 

end

function module.start( app )
    print( "Initializing MQTT" );
    if app.run ~=nil and app.get ~= nil then
        application = app
        mqtt_start()
    else
        print( "No application defined!" );
    end
end

return module
