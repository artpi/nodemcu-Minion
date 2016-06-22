-- file : application.lua
local module = {}  
local id = node.chipid()

local state = {}

local function setup() 
    --gpio.mode(1,gpio.OUTPUT)
    --gpio.mode(2,gpio.OUTPUT)
    --gpio.mode(3,gpio.OUTPUT)
    pwm.setup(1,1000,1023);
    pwm.setup(2,1000,1023);
    pwm.setup(3,1000,1023);

    state.red = 0
    state.green = 0
    state.blue = 0

    pwm.setduty(1,state.red)
    pwm.setduty(2,state.green)
    pwm.setduty(3,state.blue)
end


local function get_response()
    response = {
        id=id,
        config=config,
        state = state
    }
    return response
end

local function process_command( payload )
    if payload.action == "set" and payload.state ~= nil and payload.state.green ~= nil then
        state.green = payload.state.green
        pwm.setduty(2,state.green);
    end

    if payload.action == "set" and payload.state ~= nil and payload.state.red ~= nil then
        state.red = payload.state.red
        pwm.setduty(1,state.red);
    end

    if payload.action == "set" and payload.state ~= nil and payload.state.blue ~= nil then
        state.blue = payload.state.blue
        pwm.setduty(3,state.blue);
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
