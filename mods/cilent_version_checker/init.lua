local client_versions = {}
local client_version_channels = {}

local current_version = 0.05004

local function do_version_check(player)
    local name = player:get_player_name()
    local version = client_versions[name] or 0
    if version then
        local testversion = tonumber(version)
        if type(testversion) == "number" then
            version = testversion
        else
            version = 0
        end
    end
    if version < current_version then
        minetest.chat_send_player(name, minetest.colorize("yellow", "You need to update your clientmod. Current version: "..version..". The game might not work as intended."))
    end
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
    client_version_channels[name] = minetest.mod_channel_join(name..":client_version_channel")
    minetest.after(3,function()
        do_version_check(player)
    end)
end)

minetest.register_on_modchannel_message(function(channel_name, sender, message)
    local channel_decyphered = channel_name:gsub(sender,"")
    if channel_decyphered == ":client_version_channel" then
        client_versions[sender] = message
    end
end)

local server_version = minetest.get_version()
assert((server_version["string"] == "5.3.0-dev"),"\nThis is designed for the latest version of Minetest, please update to 5.3.0-DEV")

