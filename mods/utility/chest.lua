local chest = {}

function chest.get_chest_formspec(pos)
	local spos = pos.x .. "," .. pos.y .. "," .. pos.z
	local formspec =
		"size[9,8.75]" ..
		"listcolors[#8b8a89;#c9c3c6;#3e3d3e;#000000;#FFFFFF]"..
		"background[-0.19,-0.25;9.41,9.49;gui_hb_bg.png]"..
		"list[nodemeta:" .. spos .. ";main;0,0.3;9,4;]" ..
		"list[current_player;main;0,4.5;9,1;]" ..
		"list[current_player;main;0,6.08;9,3;8]" ..
		"listring[nodemeta:" .. spos .. ";main]" ..
		"listring[current_player;main]" --..
		--default.get_hotbar_bg(0,4.85)
	return formspec
end

function chest.chest_lid_close(pn)
	local chest_open_info = chest.open_chests[pn]
	local pos = chest_open_info.pos
	local sound = chest_open_info.sound
	local swap = chest_open_info.swap

	chest.open_chests[pn] = nil
	for k, v in pairs(chest.open_chests) do
		if v.pos.x == pos.x and v.pos.y == pos.y and v.pos.z == pos.z then
			return true
		end
	end

	local node = minetest.get_node(pos)
	minetest.after(0.2, minetest.swap_node, pos, { name = "utility:" .. swap,
			param2 = node.param2 })
	minetest.sound_play(sound, {gain = 0.3, pos = pos,
		max_hear_distance = 10}, true)
end

chest.open_chests = {}

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "utility:chest" then
		return
	end
	if not player or not fields.quit then
		return
	end
	local pn = player:get_player_name()

	if not chest.open_chests[pn] then
		return
	end

	chest.chest_lid_close(pn)
	return true
end)

minetest.register_on_leaveplayer(function(player)
	local pn = player:get_player_name()
	if chest.open_chests[pn] then
		chest.chest_lid_close(pn)
	end
end)

local function destroy_chest(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local lists = inv:get_lists()
	for listname,_ in pairs(lists) do
		local size = inv:get_size(listname)
		for i = 1,size do
			local stack = inv:get_stack(listname, i)
			minetest.add_item(pos, stack)
		end
	end
end

function chest.register_chest(name, d)
	local def = table.copy(d)
	def.drawtype = "mesh"
	def.visual = "mesh"
	def.paramtype = "light"
	def.paramtype2 = "facedir"
	def.legacy_facedir_simple = true
	def.is_ground_content = false

	if def.protected then
		def.on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			--meta:set_string("infotext", S("Locked Chest"))
			meta:set_string("owner", "")
			local inv = meta:get_inventory()
			inv:set_size("main", 9*4)
		end
		def.after_place_node = function(pos, placer)
			local meta = minetest.get_meta(pos)
			meta:set_string("owner", placer:get_player_name() or "")
			--meta:set_string("infotext", S("Locked Chest (owned by @1)", meta:get_string("owner")))
		end

		def.allow_metadata_inventory_move = function(pos, from_list, from_index,
				to_list, to_index, count, player)
			if not default.can_interact_with_node(player, pos) then
				return 0
			end
			return count
		end
		def.allow_metadata_inventory_put = function(pos, listname, index, stack, player)
			if not default.can_interact_with_node(player, pos) then
				return 0
			end
			return stack:get_count()
		end
		def.allow_metadata_inventory_take = function(pos, listname, index, stack, player)
			if not default.can_interact_with_node(player, pos) then
				return 0
			end
			return stack:get_count()
		end
		def.on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			if not default.can_interact_with_node(clicker, pos) then
				return itemstack
			end

			minetest.sound_play(def.sound_open, {gain = 0.3,
					pos = pos, max_hear_distance = 10}, true)
			
				minetest.swap_node(pos,
						{ name = "utility:" .. name .. "_open",
						param2 = node.param2 })
			 minetest.show_formspec(clicker:get_player_name(),"utility:chest", chest.get_chest_formspec(pos))
			chest.open_chests[clicker:get_player_name()] = { pos = pos,
					sound = def.sound_close, swap = name }
		end
		def.on_blast = function() end
		def.on_key_use = function(pos, player)
			local secret = minetest.get_meta(pos):get_string("key_lock_secret")
			local itemstack = player:get_wielded_item()
			local key_meta = itemstack:get_meta()

			if itemstack:get_metadata() == "" then
				return
			end

			if key_meta:get_string("secret") == "" then
				key_meta:set_string("secret", minetest.parse_json(itemstack:get_metadata()).secret)
				itemstack:set_metadata("")
			end

			if secret ~= key_meta:get_string("secret") then
				return
			end

			minetest.show_formspec(
				player:get_player_name(),
				"utility:chest_locked",
				chest.get_chest_formspec(pos)
			)
		end
		def.on_skeleton_key_use = function(pos, player, newsecret)
			local meta = minetest.get_meta(pos)
			local owner = meta:get_string("owner")
			local pn = player:get_player_name()

			-- verify placer is owner of lockable chest
			if owner ~= pn then
				minetest.record_protection_violation(pos, pn)
				--minetest.chat_send_player(pn, S("You do not own this chest."))
				return nil
			end

			local secret = meta:get_string("key_lock_secret")
			if secret == "" then
				secret = newsecret
				meta:set_string("key_lock_secret", secret)
			end

			--return secret, S("a locked chest"), owner
		end
	else
		def.on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			--meta:set_string("infotext", S("Chest"))
			local inv = meta:get_inventory()
			inv:set_size("main", 9*4)
		end
		
		def.on_rightclick = function(pos, node, clicker)
			minetest.sound_play(def.sound_open, {gain = 0.3, pos = pos,
					max_hear_distance = 10}, true)
				minetest.swap_node(pos, {
						name = "utility:" .. name .. "_open",
						param2 = node.param2 })
			 minetest.show_formspec(clicker:get_player_name(),"utility:chest", chest.get_chest_formspec(pos))
			chest.open_chests[clicker:get_player_name()] = { pos = pos,
					sound = def.sound_close, swap = name }
		end
		def.on_blast = function(pos)
			local drops = {}
			default.get_inventory_drops(pos, "main", drops)
			drops[#drops+1] = "utility:" .. name
			minetest.remove_node(pos)
			return drops
		end
	end

	def.on_metadata_inventory_move = function(pos, from_list, from_index,
			to_list, to_index, count, player)
		minetest.log("action", player:get_player_name() ..
			" moves stuff in chest at " .. minetest.pos_to_string(pos))
	end
	def.on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" moves " .. stack:get_name() ..
			" to chest at " .. minetest.pos_to_string(pos))
	end
	def.on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name() ..
			" takes " .. stack:get_name() ..
			" from chest at " .. minetest.pos_to_string(pos))
	end
	
	def.on_destruct = function(pos)
		destroy_chest(pos)
	end

	local def_opened = table.copy(def)
	local def_closed = table.copy(def)

	def_opened.mesh = "chest_open.obj"
	for i = 1, #def_opened.tiles do
		if type(def_opened.tiles[i]) == "string" then
			def_opened.tiles[i] = {name = def_opened.tiles[i], backface_culling = true}
		elseif def_opened.tiles[i].backface_culling == nil then
			def_opened.tiles[i].backface_culling = true
		end
	end
	def_opened.drop = "utility:" .. name
	def_opened.groups.not_in_creative_inventory = 1
	def_opened.selection_box = {
		type = "fixed",
		fixed = { -1/2, -1/2, -1/2, 1/2, 3/16, 1/2 },
	}

	def_opened.on_blast = function() end

	def_closed.mesh = nil
	def_closed.drawtype = nil
	def_closed.tiles[6] = def.tiles[5] -- swap textures around for "normal"
	def_closed.tiles[5] = def.tiles[3] -- drawtype to make them match the mesh
	def_closed.tiles[3] = def.tiles[3].."^[transformFX"

	minetest.register_node("utility:" .. name, def_closed)
	minetest.register_node("utility:" .. name .. "_open", def_opened)

end

chest.register_chest("chest", {
	description = "Chest",
	tiles = {
		"chest_top.png",
		"chest_top.png",
		"chest_side.png",
		"chest_side.png",
		"chest_front.png",
		"chest_inside.png"
	},
	sounds = main.woodSound(),
	sound_open = "default_chest_open",
	sound_close = "default_chest_close",
	groups = {wood = 2,  hard = 1, axe = 1, hand = 3,pathable = 1},
})

minetest.register_craft({
	output = "utility:chest",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"group:wood", "",                          "group:wood"},
		{"group:wood", "group:wood", "group:wood"},
	}
})


minetest.register_craft({
	type = "fuel",
	recipe = "utility:chest",
	burntime = 5,
})
