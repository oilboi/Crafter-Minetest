--8 power levels 8 being the highest
local color = 0
for i = 0,8 do
	local coloring = math.floor(color)

	minetest.register_node("redstone:wire_"..i,{
		description = "Redstone Wire",
		--wield_image = "redstone_wire.png^[colorize:red:"..coloring,
		paramtype = "light",
		drawtype = "nodebox",
		power = i,
		--paramtype2 = "wallmounted",
		walkable = false,
		node_box = {
			type = "connected",
			--{xmin, ymin, zmin, xmax, ymax, zmax}

			fixed = {-1/16, -1/2, -1/16, 1/16, -7/16, 1/16},
			
			disconnected_sides  = {-1/16, -1/2, -1/16, 1/16, 1/2, 1/16},

			connect_top = {-1/16, -1/2, -1/16, 1/16, 1/2, 1/16},
			-- connect_bottom =
			connect_front = {-1/16, -1/2, -1/2, 1/16, -7/16, 1/16},
			connect_left =  {-1/2, -1/2, -1/16, 1/16, -7/16, 1/16},
			connect_back =  {-1/16, -1/2, -1/16, 1/16, -7/16, 1/2},
			connect_right = {-1/16, -1/2, -1/16, 1/2, -7/16, 1/16},
		},
		collision_box = {
			type = "connected",
			--{xmin, ymin, zmin, xmax, ymax, zmax}

			fixed = {-1/16, -1/2, -1/16, 1/16, -7/16, 1/16},
			-- connect_top =
			-- connect_bottom =
			connect_front = {-1/16, -1/2, -1/2, 1/16, -7/16, 1/16},
			connect_left =  {-1/2, -1/2, -1/16, 1/16, -7/16, 1/16},
			connect_back =  {-1/16, -1/2, -1/16, 1/16, -7/16, 1/2},
			connect_right = {-1/16, -1/2, -1/16, 1/2, -7/16, 1/16},
		},
		connects_to = {"group:redstone"},
		inventory_image = "dirt.png",
		wield_image = "dirt.png",
		tiles = {"redstone_wire.png^[colorize:red:"..coloring},
		sunlight_propagates = true,
		is_ground_content = false,
		groups = {redstone =1, instant=1,redstone=1,redstone_wire=1},
		on_place = function(itemstack, placer, pointed_thing)
			minetest.item_place_node(itemstack, placer, pointed_thing)
			redstone.update(pointed_thing.above)
		end,
		on_dig = function(pos, node, digger)
			minetest.node_dig(pos, node, digger)
			redstone.update(pos,node)
		end,
	})
	color= color +31.875
end
