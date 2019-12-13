# bellhop

bellhop is an IRC bot written in Lua.

## Installation

### Prerequisite packages

Please install the following packages on your package manager before attempting to install bellhop:

1. awk
2. m4
3. openssl development headers (Ubuntu: libssl-dev)
4. luarocks

### Installing bellhop

1. Clone the repository: `git clone https://github.com/leonardus/bellhop`
2. Install luarocks dependencies: `# luarocks lua-toml lbase64`
3. Copy `config.sample.toml` into `config.toml` and configure to your liking
4. Run: `cd bellhop && lua main.lua` - make sure you are launching `main.lua` from the `bellhop` directory
5. Report any bugs to this repository
