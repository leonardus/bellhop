return function(connection, line, substitution)
    connection:send(line .. "\r\n")
    print("-> " .. (substitution or line))
end