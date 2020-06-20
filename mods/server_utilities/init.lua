local minetest,os = minetest,os
local mod_storage = minetest.get_mod_storage()
local pool = {}
local home_timeout = 60

--this does not terminate data because player's can spam
--leave and come back in to reset the home timout


minetest.register_chatcommand("sethome", {
	params = "nil",
	description = "Use this to set your home. Can be returned to by setting /home",
	privs = {},
	func = function(name)
		local time = minetest.get_us_time()/1000000
		local player = minetest.get_player_by_name(name)
		local pos = player:get_pos()
		if not pool[name] or pool[name] and time-pool[name] > home_timeout then
			mod_storage:set_string(name.."home", minetest.serialize(pos))
			pool[name] = time
			minetest.chat_send_player(name, "Home set.")
		elseif pool[name] then
			local diff = home_timeout-math.ceil(time-pool[name])+1
			local s = "s"
			if diff == 1 then
				s = ""
			end
			minetest.chat_send_player(name, diff.." more second"..s.." until you can run that command.")
		end
	end,
})


minetest.register_chatcommand("home", {
	params = "nil",
	description = "Use this to set your home. Can be returned to by setting /home",
	privs = {},
	func = function(name)
		local time = minetest.get_us_time()/1000000
		local player = minetest.get_player_by_name(name)

		if not pool[name] or pool[name] and time-pool[name] > home_timeout then

			local newpos = minetest.deserialize(mod_storage:get_string(name.."home"))
			
			if newpos then
				player:add_player_velocity(vector.multiply(player:get_player_velocity(),-1))
				player:move_to(newpos)
				pool[name] = time
			else
				minetest.chat_send_player(name, "No home set.")
			end
		elseif pool[name] then
			local diff = home_timeout-math.ceil(time-pool[name])+1
			local s = "s"
			if diff == 1 then
				s = ""
			end
			minetest.chat_send_player(name, diff.." more second"..s.." until you can run that command.")
		end
	end,
})