local socket = require("socket")
local base64 = require("base64")

local config = require("config")
local parse = require("util.parse")
local subparse = require("util.subparse")
local send = require("util.send")

local client = socket.connect(
    config.server.network,
    config.server.port
)

local commands = {}
for _, command in pairs(config.bot.enabled_commands) do
    command = command:upper()
    commands[command] = require("commands." .. command)
end

-- Connection registration
if config.services.useSASL == true then
    send(client, "CAP REQ :sasl")
end
send(client, "NICK " .. config.bot.nick)
send(client, "USER " .. config.bot.username .. " 0 * :" .. config.bot.realname)

local function completeRegistration(client)
    for _, channel in pairs(config.server.channels) do
        send(client, "JOIN " .. channel)
    end
end

local function SASL(client, line)
    if line.command == "CAP" then
        if line.args[2] == "ACK" and line.args[3]:find("sasl") then
            send(client, "AUTHENTICATE PLAIN")
        end
    end
    if line.command == "AUTHENTICATE" and line.args[1] == "+" then
        local payload = config.services.username .. "\0" .. config.services.username .. "\0" .. config.services.password
        -- TODO: Do not send b64 strings longer than 400b
        send(client, "AUTHENTICATE " .. base64.encode(payload), "(SASL authentication response)")
    end
    if line.command == "903" then
        send(client, "CAP END")
        completeRegistration(client)
        return true
    end
    if line.command == "904" then
        print("FATAL: Could not authenticate with SASL. Exiting.")
        client:close()
    end
end

-- Main loop
local registered = false
while true do
    local next, err = client:receive("*l")
    if err == "closed" then
        break
    end
    print("<- " .. next)

    local line = parse(next)
    if not line then
        print("WARN: Failed to parse: " .. next)
        goto continue
    end

    -- SASL/registration
    if registered == false then
        if config.services.useSASL == true then
            local success = SASL(client, line)
            if success then
                registered = true
            end
        else
            completeRegistration(client)
            registered = true
        end
    end

    if line.command == "ERROR" then
        client:close()
    end

    if line.command == "PING" then
        send(client, "PONG")
    end

    if line.command == "PRIVMSG" then
        local subcommand, subargs = subparse(line.args[2])
        print(subcommand, subcommand:len(), subcommand:sub(1,1))
        if subcommand and subcommand:len() > 1 and subcommand:sub(1,1) == config.bot.prefix then
            subcommand = subcommand:sub(2):upper()
            if commands[subcommand] then
                commands[subcommand](client, line, subargs)
            end
        end
    end

    ::continue::
end