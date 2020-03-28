for level = 0,9 do
local subtracter = 0
if level > 0 then subtracter = 1 end
minetest.register_node("redstone:pressure_plate_"..level, {
    description = "Pressure Plate",
    tiles = {"stone.png"},
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,attached_node = 1,redstone_torch=level, redstone_power=level,pressure_plate=level+1,pressure_plate_on=level},
    sounds = main.stoneSound(),
    paramtype = "light",
	--paramtype2 = "facedir",
	sunlight_propagates = true,
	--walkable = false,
	drawtype= "nodebox",
	drop="redstone:pressure_plate_0",
	node_box = {
		type = "fixed",
		fixed = {
				--left  front  bottom right back top
				{-0.5, -0.5,  -0.5, 0.5,  -0.4-(0.05*subtracter), 0.5}
			},
		},
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
	end,
	redstone_activation = function(pos)
	end,
	redstone_deactivation = function(pos)
	end,
	on_timer = function(pos, elapsed)
	end,
	on_dig = function(pos, node, digger)
		redstone.collect_info(pos)
		minetest.node_dig(pos, node, digger)
	end,
	redstone_update = function(pos)
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
	end,
	on_construct = function(pos)
	end,
	after_destruct = function(pos)
	end,
})
end


minetest.register_abm{
    label = "Redstone Pressure Plate",
	nodenames = {"group:pressure_plate"},
	--neighbors = {"group:water"},
	interval = 0.1,
	chance = 1,
	action = function(pos)
		local power_level = 0
		local level = minetest.get_node_group(minetest.get_node(pos).name, "pressure_plate_on")
		--detect players
		for _,object in ipairs(minetest.get_objects_inside_radius(pos, 1.2)) do
			if object:is_player() and object:get_hp() > 0 then
				local pos2 = object:get_pos()
				local compare = vector.subtract(pos2,pos)
				local real_y = compare.y
				compare = vector.abs(compare)
				if real_y <= -0.35 and real_y > -0.5 and compare.x < 0.8 and compare.z < 0.8 then
					power_level = 9
				end
			end
		end
		--detect items
		if power_level ~= 9 then
			for _,object in ipairs(minetest.get_objects_inside_radius(pos, 1.2)) do
				if not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "__builtin:item" then
					local pos2 = object:get_pos()
					pos2.y = pos2.y + object:get_properties().collisionbox[2]
					local compare = vector.subtract(pos2,pos)
					local real_y = compare.y
					compare = vector.abs(compare)
					if real_y <= -0.35 and real_y > -0.5 and compare.x < 0.6 and compare.z < 0.6 then
						if power_level < 9 then
							power_level = power_level + 1
						else
							break
						end
					end
				end
			end	
		end
		if level ~= power_level then
			minetest.sound_play("lever", {pos=pos})
			minetest.swap_node(pos,{name="redstone:pressure_plate_"..power_level})
			redstone.collect_info(pos)
		end
	end,
}
