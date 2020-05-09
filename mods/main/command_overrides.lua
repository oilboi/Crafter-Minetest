 core.register_chatcommand("clearobjects", {
	params = "[full | quick]",
	description = "Clear all objects in world",
	privs = {server=true},
	func = function(name, param)
		local options = {}
		if param == "" or param == "quick" then
			options.mode = "quick"
		elseif param == "full" then
			options.mode = "full"
		else
			return false, "Invalid usage, see /help clearobjects."
		end

		core.log("action", name .. " clears all objects ("
				.. options.mode .. " mode).")
		core.chat_send_all("Clearing all objects. This may take a long time."
				.. " You may experience a timeout. (by "
				.. name .. ")")
		core.clear_objects(options)
		core.log("action", "Object clearing done.")
		core.chat_send_all("*** Cleared all objects.")
		global_mob_amount = 0
		return true
	end,
})
