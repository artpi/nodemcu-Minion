-- file : application.lua
local module = {}  
local id = node.chipid()

local state = {}

local pin = {}

local function switch_check()
    status = 1 - gpio.read( pin.switch );
    if status ~= state.switch then
        state.switch = status;
        state.power=state.switch;
        gpio.write( pin.power, state.power );
    end
end

local function setup()
    if config.mode == nil then
    elseif config.mode == "switch" then
        pin.power = 3;
        pin.switch = 2;

        state.power = 0;
        state.switch = 0;
        gpio.mode(pin.switch, gpio.INPUT, gpio.PULLUP);
        gpio.write(pin.power, gpio.LOW);
        tmr.alarm(4, 500, 1, switch_check );
    elseif config.mode == "rgb" then
        pin.red = 1;
        pin.green = 2;
        pin.blue = 3;

        pwm.setup(pin.red,1000,1023);
        pwm.setup(pin.green,1000,1023);
        pwm.setup(pin.blue,1000,1023);

        state.red = 0
        state.green = 0
        state.blue = 0

        pwm.setduty(pin.red,state.red);
        pwm.setduty(pin.green,state.green);
        pwm.setduty(pin.blue,state.blue);
    end

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
    if pin[key] ~= nil and payload.state[key] ~= nil then
        state[key] = payload.state[key];
        if state[key] == 1 then
            gpio.write(pin[key], gpio.HIGH);
        elseif state[key] == 0 then
            gpio.write(pin[key], gpio.LOW);
        end
    end
end

local function set_pin_state_pwm( payload, key )
    if pin[key] ~= nil and payload.state[key] ~= nil then
        state[key]= payload.state[key];
        pwm.setduty(pin[key],state[key]);
    end
end



local function process_command( payload )
    if payload.action == "set-config" and payload.config ~= nil then
        file.open("config.json", "w")
        file.writeline( cjson.encode( payload.config ) )
        file.close()
    end

    if payload.action == "set" and payload.state ~= nil then
        --Will work only for switch mode
        set_pin_state( payload, 'power' );

        --Will work only for rgb mode
        set_pin_state_pwm( payload, 'red' );
        set_pin_state_pwm( payload, 'green' );
        set_pin_state_pwm( payload, 'blue' );
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
