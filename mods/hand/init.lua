-- The hand

--Create an initial hand tool
minetest.register_item(":", {
	type = "none",
	wield_image = "wieldhand.png",
	wield_scale = {x=1,y=1,z=2.5},
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level = 0,
		groupcaps = {
			stone = {times={[4]=11.5,[3]=8.5,[2]=6.70,[1]=5.5}, uses=0, maxlevel=1},
			dirt = {times={[4]=11.0,[3]=8.4,[2]=6.40,[1]=4.2}, uses=0, maxlevel=1},
			sand = {times={[4]=11.0,[3]=8.4,[2]=6.40,[1]=4.2}, uses=0, maxlevel=1},
			wood = {times={[4]=11.5,[3]=8.5,[2]=6.70,[1]=5.5}, uses=0, maxlevel=1},
			leaves = {times={[4]=4.5,[3]=3.2,[2]=2.20,[1]=1.2}, uses=0, maxlevel=0},
			wool = {times={[4]=4.5,[3]=3.2,[2]=2.20,[1]=1.2}, uses=0, maxlevel=0},
			instant = {times={[1]=0.1,},uses=0,maxlevel=1},
			dig_immediate = {times={[2]=0,[3]=0,[1]=0,},uses=0,maxlevel=1},
		},
		damage_groups = {fleshy=1},
	}
})

-- This is a fake node that should never be placed in the world
local def = minetest.registered_items[""]
minetest.register_node("hand:player", {
	description = "",
	tiles = {"player.png"},
	visual_scale = 1,
	wield_scale = {x=1,y=1,z=1},
	paramtype = "light",
	drawtype = "mesh",
	mesh = "hand.b3d",
	-- Prevent construction
	node_placement_prediction = "",
	on_construct = function(pos)
		minetest.log("error", "Tried to place hand at "..minetest.pos_to_string(pos))
		minetest.remove_node(pos)
	end,
	drop = "",
	on_drop = function()
		return ""
	end,
	groups = { dig_immediate = 3, not_in_creative_inventory = 1 },
	range = def.range,
})


--Create a hand list and then enable the hand node
minetest.register_on_joinplayer(function(player)
	player:get_inventory():set_size("hand", 1)
	player:get_inventory():set_stack("hand", 1, "hand:player")
end)

