local config = require("config")

return function(host)
    for _, adminHost in pairs(config.bot.admins) do
        if adminHost == host then
            return true
        end
    end
    return false
end