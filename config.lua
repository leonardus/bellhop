local toml = require("toml")
local readfile = require("util.readfile")
return toml.parse(readfile("config.toml"))