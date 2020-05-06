local farmland = {"wet","dry"}

for level,dryness in pairs(farmland) do
	local coloring = 160/level

	minetest.register_node("farming:farmland_"..dryness,{
		description = "Farmland",
		paramtype = "light",
		drawtype = "nodebox",
		sounds = main.dirtSound(),
		--paramtype2 = "wallmounted",
		node_box = {
			type = "fixed",
			--{xmin, ymin, zmin, xmax, ymax, zmax}

			fixed = {-0.5, -0.5, -0.5, 0.5, 6/16, 0.5},
		},
		wetness = math.abs(level-2),
		collision_box = {
			type = "fixed",
			--{xmin, ymin, zmin, xmax, ymax, zmax}

			fixed = {-0.5, -0.5, -0.5, 0.5, 6/16, 0.5},
		},
		tiles = {"dirt.png^farmland.png^[colorize:black:"..coloring,"dirt.png^[colorize:black:"..coloring,"dirt.png^[colorize:black:"..coloring,"dirt.png^[colorize:black:"..coloring,"dirt.png^[colorize:black:"..coloring,"dirt.png^[colorize:black:"..coloring},
		groups = {dirt = 1, soft = 1, shovel = 1, hand = 1, soil=1,farmland=1},
		drop="main:dirt",
	})
end


--drying and wetting abm for farmland
minetest.register_abm({
	label = "Farmland Wet",
	nodenames = {"farming:farmland_dry"},
	neighbors = {"air","group:crop"},
	interval = 3,
	chance = 150,
	action = function(pos)
		local found = minetest.find_node_near(pos, 3, {"main:water","main:waterflow"})
		if found then
			minetest.set_node(pos,{name="farming:farmland_wet"})
		else
			minetest.set_node(pos,{name="main:dirt"})
		end
	end,
})
minetest.register_abm({
	label = "Farmland dry",
	nodenames = {"farming:farmland_wet"},
	neighbors = {"air"},
	interval = 5,
	chance = 500,
	action = function(pos)
		local found = minetest.find_node_near(pos, 3, {"main:water","main:waterflow"})
		if not found then
			minetest.set_node(pos,{name="farming:farmland_dry"})
		end
	end,
})
 
