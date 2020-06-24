core.register_chatcommand("clearinv", {
	params = "[<name>]",
    description = "Clear the inventory of yourself or another player",
    privs = {server = true},
	func = function(name, param)
		local player
		if param and param ~= "" and param ~= name then
			if not core.check_player_privs(name, {server=true}) then
				return false, "You don't have permission"
						.. " to clear another player's inventory (missing privilege: server)"
			end
			player = core.get_player_by_name(param)
			core.chat_send_player(param, name.." cleared your inventory.")
		else
			player = core.get_player_by_name(name)
		end

		if player then
			player:get_inventory():set_list("main", {})
			player:get_inventory():set_list("craft", {})
            player:get_inventory():set_list("craftpreview", {})
            player:get_inventory():set_list("armor_head", {})
            player:get_inventory():set_list("armor_torso", {})
            player:get_inventory():set_list("armor_legs", {})
            player:get_inventory():set_list("armor_feet", {})
            
			core.log("action", name.." clears "..player:get_player_name().."'s inventory")
			return true, "Cleared "..player:get_player_name().."'s inventory."
		else
			return false, "Player must be online to clear inventory!"
		end
	end,
})
