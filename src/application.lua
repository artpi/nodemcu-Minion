-- file : application.lua
local module = {}  
local id = node.chipid()

local state = {}

local pin = {
    d4 = 4,
    d5 = 5,
    d6 = 6
}

local function setup( config )
    gpio.mode(pin.d4,gpio.OUTPUT);
    gpio.mode(pin.d5,gpio.OUTPUT);
    gpio.mode(pin.d6,gpio.OUTPUT);

    pwm.setup(1,1000,1023);
    pwm.setup(2,1000,1023);
    pwm.setup(3,1000,1023);

    state.red = 0
    state.green = 0
    state.blue = 0

    pwm.setduty(1,state.red);
    pwm.setduty(2,state.green);
    pwm.setduty(3,state.blue);

    state.d4 = 0;
    state.d5 = 0;
    state.d6 = 0;

    gpio.write(pin.d4, gpio.HIGH)
    gpio.write(pin.d5, gpio.HIGH)
    gpio.write(pin.d6, gpio.HIGH)
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
            gpio.write(pin[key], gpio.LOW);
        elseif state[key] == 0 then
            gpio.write(pin[key], gpio.HIGH);
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
        if payload.state.green ~= nil then
            state.green = payload.state.green;
            pwm.setduty(2,state.green);
        end

        if payload.state.red ~= nil then
            state.red = payload.state.red;
            pwm.setduty(1,state.red);
        end

        if payload.state.blue ~= nil then
            state.blue = payload.state.blue;
            pwm.setduty(3,state.blue);
        end

        set_pin_state( payload, 'd4' );
        set_pin_state( payload, 'd5' );
        set_pin_state( payload, 'd6' );

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
