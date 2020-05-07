local farmland = {"wet","dry"}

for level,dryness in pairs(farmland) do
	local coloring = 160/level
	local on_construct
	if dryness == "wet" then
		on_construct = function(pos)
			local found = minetest.find_node_near(pos, 3, {"main:water","main:waterflow"})
			if not found then
				minetest.set_node(pos,{name="farming:farmland_dry"})
			end
			local timer = minetest.get_node_timer(pos)
			timer:start(1)
		end
		
		on_timer = function(pos)
			local found = minetest.find_node_near(pos, 3, {"main:water","main:waterflow"})
			if not found then
				minetest.set_node(pos,{name="farming:farmland_dry"})
			end
			local timer = minetest.get_node_timer(pos)
			timer:start(math.random(10,25))
		end
	else
		on_construct = function(pos)
			local timer = minetest.get_node_timer(pos)
			timer:start(math.random(10,25))
		end
		
		on_timer = function(pos)
			local found = minetest.find_node_near(pos, 3, {"main:water","main:waterflow"})
			if found then
				minetest.set_node(pos,{name="farming:farmland_wet"})
				local timer = minetest.get_node_timer(pos)
				timer:start(1)
			else
				minetest.set_node(pos,{name="main:dirt"})
				if minetest.get_node_group(minetest.get_node(vector.new(pos.x,pos.y+1,pos.z)).name, "plant") > 0 then
					minetest.dig_node(vector.new(pos.x,pos.y+1,pos.z))
				end
			end
		end
	end
	
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
		on_construct = on_construct,
		on_timer = on_timer,
	})
end
