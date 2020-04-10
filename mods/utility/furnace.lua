local furnace = {}

function furnace.get_furnace_active_formspec(fuel_percent, item_percent)
	return "size[9,8.75]"..
		"background[-0.19,-0.25;9.41,9.49;gui_hb_bg.png]"..
		"listcolors[#8b8a89;#c9c3c6;#3e3d3e;#000000;#FFFFFF]"..
		"list[context;src;2.75,0.5;1,1;]"..
		"list[context;fuel;2.75,2.5;1,1;]"..
		"image[2.75,1.5;1,1;default_furnace_fire_bg.png^[lowpart:"..
		(fuel_percent)..":default_furnace_fire_fg.png]"..
		"image[3.75,1.5;1,1;gui_furnace_arrow_bg.png^[lowpart:"..
		(item_percent)..":gui_furnace_arrow_fg.png^[transformR270]"..
		"list[context;dst;4.75,0.96;2,2;]"..
		"list[current_player;main;0,4.5;9,1;]".. --hotbar
		"list[current_player;main;0,6;9,3;9]".. --inventory
		
		"listring[context;dst]"..
		"listring[current_player;main]"..
		"listring[context;src]"..
		"listring[current_player;main]"..
		"listring[context;fuel]"..
		"listring[current_player;main]"
		--furnace.get_hotbar_bg(0, 4.25)
end

function furnace.get_furnace_inactive_formspec()
	return "size[9,8.75]"..
		"background[-0.19,-0.25;9.41,9.49;gui_hb_bg.png]"..
		"listcolors[#8b8a89;#c9c3c6;#3e3d3e;#000000;#FFFFFF]"..
		"list[context;src;2.75,0.5;1,1;]"..
		"list[context;fuel;2.75,2.5;1,1;]"..
		"image[2.75,1.5;1,1;default_furnace_fire_bg.png]"..
		"image[3.75,1.5;1,1;gui_furnace_arrow_bg.png^[transformR270]"..
		"list[context;dst;4.75,0.96;2,2;]"..
		"list[current_player;main;0,4.5;9,1;]"..
		"list[current_player;main;0,6;9,3;9]"..
		"listring[context;dst]"..
		"listring[current_player;main]"..
		"listring[context;src]"..
		"listring[current_player;main]"..
		"listring[context;fuel]"..
		"listring[current_player;main]"
		--furnace.get_hotbar_bg(0, 4.25)
end

--
-- Node callback functions that are the same for active and inactive furnace
--

--[[
local function can_dig(pos, player)
	local meta = minetest.get_meta(pos);
	local inv = meta:get_inventory()
	return inv:is_empty("fuel") and inv:is_empty("dst") and inv:is_empty("src")
end
]]--

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if listname == "fuel" then
		if minetest.get_craft_result({method="fuel", width=1, items={stack}}).time ~= 0 then
			--if inv:is_empty("src") then
			--	meta:set_string("infotext", "Furnace is empty")
			--end
			return stack:get_count()
		else
			return 0
		end
	elseif listname == "src" then
		return stack:get_count()
	elseif listname == "dst" then
		return 0
	end
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end

local function swap_node(pos, name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos, node)
end

local function furnace_node_timer(pos, elapsed)
	--
	-- Initialize metadata
	--
	local meta = minetest.get_meta(pos)
	local fuel_time = meta:get_float("fuel_time") or 0
	local src_time = meta:get_float("src_time") or 0
	local fuel_totaltime = meta:get_float("fuel_totaltime") or 0

	local inv = meta:get_inventory()
	local srclist, fuellist
	local dst_full = false

	local cookable, cooked
	local fuel

	local update = true
	while elapsed > 0 and update do
		update = false

		srclist = inv:get_list("src")
		fuellist = inv:get_list("fuel")

		--
		-- Cooking
		--

		-- Check if we have cookable content
		local aftercooked
		cooked, aftercooked = minetest.get_craft_result({method = "cooking", width = 1, items = srclist})
		cookable = cooked.time ~= 0

		local el = math.min(elapsed, fuel_totaltime - fuel_time)
		if cookable then -- fuel lasts long enough, adjust el to cooking duration
			el = math.min(el, cooked.time - src_time)
		end

		-- Check if we have enough fuel to burn
		if fuel_time < fuel_totaltime then
			-- The furnace is currently active and has enough fuel
			fuel_time = fuel_time + el
			-- If there is a cookable item then check if it is ready yet
			if cookable then
				src_time = src_time + el
				if src_time >= cooked.time then
					-- Place result in dst list if possible
					if inv:room_for_item("dst", cooked.item) then
						inv:add_item("dst", cooked.item)
						inv:set_stack("src", 1, aftercooked.items[1])
						src_time = src_time - cooked.time
						update = true
					else
						dst_full = true
					end
				else
					-- Item could not be cooked: probably missing fuel
					update = true
				end
			end
		else
			-- Furnace ran out of fuel
			if cookable then
				-- We need to get new fuel
				local afterfuel
				fuel, afterfuel = minetest.get_craft_result({method = "fuel", width = 1, items = fuellist})

				if fuel.time == 0 then
					-- No valid fuel in fuel list
					fuel_totaltime = 0
					src_time = 0
				else
					-- Take fuel from fuel list
					inv:set_stack("fuel", 1, afterfuel.items[1])
					-- Put replacements in dst list or drop them on the furnace.
					local replacements = fuel.replacements
					if replacements[1] then
						local leftover = inv:add_item("dst", replacements[1])
						if not leftover:is_empty() then
							local above = vector.new(pos.x, pos.y + 1, pos.z)
							local drop_pos = minetest.find_node_near(above, 1, {"air"}) or above
							minetest.item_drop(replacements[1], nil, drop_pos)
						end
					end
					update = true
					fuel_totaltime = fuel.time + (fuel_totaltime - fuel_time)
				end
			else
				-- We don't need to get new fuel since there is no cookable item
				fuel_totaltime = 0
				src_time = 0
			end
			fuel_time = 0
		end

		elapsed = elapsed - el
	end

	if fuel and fuel_totaltime > fuel.time then
		fuel_totaltime = fuel.time
	end
	if srclist and srclist[1]:is_empty() then
		src_time = 0
	end

	--
	-- Update formspec, infotext and node
	--
	local formspec
	local item_state
	local item_percent = 0
	if cookable then
		item_percent = math.floor(src_time / cooked.time * 100)
		if dst_full then
			item_state = ("100% (output full)")
		else
			item_state = (item_percent)
		end
	else
		if srclist and not srclist[1]:is_empty() then
			item_state = ("Not cookable")
		else
			item_state = ("Empty")
		end
	end

	local fuel_state = ("Empty")
	local active = false
	local result = false

	if fuel_totaltime ~= 0 then
		active = true
		local fuel_percent = 100 - math.floor(fuel_time / fuel_totaltime * 100)
		fuel_state = (fuel_percent)
		formspec = furnace.get_furnace_active_formspec(fuel_percent, item_percent)
		swap_node(pos, "utility:furnace_active")
		-- make sure timer restarts automatically
		result = true
	else
		if fuellist and not fuellist[1]:is_empty() then
			fuel_state = (0)
		end
		formspec = furnace.get_furnace_inactive_formspec()
		swap_node(pos, "utility:furnace")
		-- stop timer on the inactive furnace
		minetest.get_node_timer(pos):stop()
	end


	--[[
	local infotext
	if active then
		infotext = ("Furnace active")
	else
		infotext = ("Furnace inactive")
	end
	infotext = infotext .. "\n" .. "Item:"..item_state.. "Fuel:"..fuel_state
	]]--
	--
	-- Set meta values
	--
	meta:set_float("fuel_totaltime", fuel_totaltime)
	meta:set_float("fuel_time", fuel_time)
	meta:set_float("src_time", src_time)
	meta:set_string("formspec", formspec)
	--meta:set_string("infotext", infotext)

	return result
end
--throw all items in furnace out on destroy
local function destroy_furnace(pos)
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

--
-- Node definitions
--

minetest.register_node("utility:furnace", {
	description = ("Furnace"),
	tiles = {
		"furnace_top.png", "furnace_bottom.png",
		"furnace_side.png", "furnace_side.png",
		"furnace_side.png", "furnace_front.png"
	},
	paramtype2 = "facedir",
	groups = {stone=2},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = main.stoneSound(),

	--can_dig = can_dig,

	on_timer = furnace_node_timer,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size('src', 1)
		inv:set_size('fuel', 1)
		inv:set_size('dst', 4)
		furnace_node_timer(pos, 0)
	end,

	on_metadata_inventory_move = function(pos)
		local timer = minetest.get_node_timer(pos)
		if timer:is_started() == false then
			timer:start(1.0)
		end
	end,
	on_metadata_inventory_put = function(pos)
		-- start timer function, it will sort out whether furnace can burn or not.
		local timer = minetest.get_node_timer(pos)
		if timer:is_started() == false then
			timer:start(1.0)
		end
	end,
	--[[
	on_blast = function(pos)
		local drops = {}
		furnace.get_inventory_drops(pos, "src", drops)
		furnace.get_inventory_drops(pos, "fuel", drops)
		furnace.get_inventory_drops(pos, "dst", drops)
		drops[#drops+1] = "utility:furnace"
		minetest.remove_node(pos)
		return drops
	end,
	]]--
	on_destruct = function(pos)
		destroy_furnace(pos)
	end,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
})

minetest.register_node("utility:furnace_active", {
	description = ("Furnace"),
	tiles = {
		"furnace_top.png", "furnace_bottom.png",
		"furnace_side.png", "furnace_side.png",
		"furnace_side.png",
		{
			image = "furnace_front_active.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.5
			},
		}
	},
	paramtype2 = "facedir",
	light_source = 8,
	drop = "utility:furnace",
	groups = {stone=2},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = main.stoneSound(),
	on_timer = furnace_node_timer,

	--can_dig = can_dig,

	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	on_destruct = function(pos)
		destroy_furnace(pos)
	end,
})

minetest.register_craft({
	output = "utility:furnace",
	recipe = {
		{"group:stone", "group:stone", "group:stone"},
		{"group:stone", "", "group:stone"},
		{"group:stone", "group:stone", "group:stone"},
	}
})
