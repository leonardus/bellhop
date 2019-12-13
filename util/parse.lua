local re = require("re")

local pattern = re.compile(
    [[
        -- tags, command, args
        line <- {|
            {:tags: {| (tags sp)? |} :}
            {:prefix: {| (prefix sp)? |} :}
            {:command: (command / numeric) :}
            {:args: {| (sp arg)* |} :} |}
        tags <- '@' tag (';' tag)*
        tag <- {|
            {:is_client: {'+'} :}? -- check: if tag.is_client
            {:vendor: {[^/]+} '/' :}?
            {:key: {[^=; ]+} -> esc_tag :}
            {:value: ('=' {[^; ]*} -> esc_tag) :}?
        |}
        prefix <- ':' (
            {:nick: {[^ !]+} :} '!'
            {:user: {[^ @]+} :} '@'
            {:host: {[^ ]+} :} /
            {:server: {[^ ]+} :})
        command <- [A-Za-z]+
        numeric <- %d^+3^-4 -- at most four digits, at least three
        arg <- ':' {.+} / {[^ ]+}
        sp <- %s
    ]],
    {esc_tag = function(tag)
        return tag:gsub(
            "\\(.)",
            setmetatable(
                {
                    [":"] = ";",
                    s = " ",
                    r = "\r",
                    n = "\n"
                },
                {__index = function (t, k)
                    return k
                end}
            )
        )
    end}
)

return function(rawIrc)
    return re.match(rawIrc, pattern)
end