--we need to do this to tell the client we're ready to start up
minetest.register_on_mods_loaded(function()
	open_all_client_modchannels = minetest.mod_channel_join("initializer")
end)
