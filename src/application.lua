-- file : application.lua
local module = {}  
local id = node.chipid()

local state = {}

local pin = {
    power = 3,
    switch = 2
}

local function check_switch()
    status = 1 - gpio.read( pin.switch );
    if status ~= state.switch then
        state.switch = status;
        gpio.write( pin.power, state.switch );
    end
end

local function setup( config )
    state.power = 0;
    state.switch = 0;
    gpio.mode(pin.switch, gpio.INPUT, gpio.PULLUP);
    gpio.write(pin.power, gpio.LOW);
    tmr.alarm(4, 500, 1, check_switch );
end


local function get_response()
    response = {
        id=id,
        config=config,
        state = state
    }
    return response
end

local function set_pin_state( payload, key )
    if payload.state[key] ~= nil then
        state[key] = payload.state[key];
        if state[key] == 1 then
            gpio.write(pin[key], gpio.HIGH);
        elseif state[key] == 0 then
            gpio.write(pin[key], gpio.LOW);
        end
    end
end

local function process_command( payload )
    if payload.action == "set-config" and payload.config ~= nil then
        file.open("config.json", "w")
        file.writeline( cjson.encode( payload.config ) )
        file.close()
    end

    if payload.action == "set" and payload.state ~= nil then
        set_pin_state( payload, 'power' );
    end
end

function module.setup( config )  
    setup( config )
    return module 
end

function module.run( command )  
    process_command( command )
end

function module.get()  
    return get_response()
end

return module
