local isadmin = require("util.isadmin")

return function(client, line)
    if line.prefix.host and isadmin(line.prefix.host) then
        client:close()
    end
end