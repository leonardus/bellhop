return function (target)
    local t = {}
    for token in string.gmatch(target, "[^ ]+") do
        table.insert(t, token)
    end
    local command = t[1]
    local args = {}
    if #t > 1 then
        for i = 2, #t do
            table.insert(args, t[i])
        end
    end
    return command, args
end