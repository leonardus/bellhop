local isadmin = require("util.isadmin")
local send = require("util.send")

return function(client, line, subargs)
    if line.prefix.host and isadmin(line.prefix.host) then
        if #subargs > 0 then
            for _, channel in pairs(subargs) do
                if channel:sub(1,1) == "#" then
                    send(client, "PART :" .. channel)
                end
            end
        elseif line.args[1]:sub(1,1) == "#" then
            send(client, "PART :" .. line.args[1])
        end
    end
end