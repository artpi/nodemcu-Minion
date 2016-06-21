-- Simple http endpoint
local module = {}  

local function http_start()
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
  conn:on("receive",function(conn,payload)
  	json = string.match(payload, "{.*}")
    ok, data = pcall(cjson.decode,json)
    if json ~=nil and ok then
        if data.action == "set-config" and data.config ~= nil then
            file.open("config.json", "w")
            file.writeline( cjson.encode( data.config ) )                                                
            file.close()
            conn:send('HTTP/1.1 200 OK\n\n')
        end
        if data.action == "get-config" then
			file.open("config.json")
			current = file.readline()
			file.close()
            conn:send('HTTP/1.1 200 OK\n\n' .. current)
        end
    else
    	conn:send('HTTP/1.1 400 Bad json payload\n\n')
	end
  end)
  conn:on("sent",function(conn) conn:close() end)
end)
end

function module.start()  
  http_start()
end

return module
