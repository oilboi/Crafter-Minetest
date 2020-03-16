--[[

redstone powder is raillike

check if solid block above
--if so, do not conduct above

uses height level to do powerlevel

uses lightlevel
a function for adding and removing redstone level

]]--



---set a torch source



local path = minetest.get_modpath("redstone")
dofile(path.."/wire.lua")
dofile(path.."/torch.lua")

redstone = {}

--this is the internal check for getting the max_power 
function redstone.update_everything(pos)
	local range = 1
	local min = vector.add(pos,range)
	local max = vector.subtract(pos,range)
	local vm = minetest.get_voxel_manip()	
	local emin, emax = vm:read_from_map(min,max)
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()
	local content_id = minetest.get_name_from_content_id
	local origin_pos = area:index(pos.x,pos.y,pos.z)
	local origin_n = content_id(data[origin_pos])
	local origin_level = minetest.registered_nodes[origin_n].power
	local max_level = 0
	
	for x=-range, range do
	for y=-range, range do
	for z=-range, range do
			if not vector.equals(pos, vector.add(pos,vector.new(x,y,z))) then
				local p_pos = area:index(pos.x+x,pos.y+y,pos.z+z)							
				local n = content_id(data[p_pos])
				
				local level2 = minetest.registered_nodes[n].power
				
				if level2 and level2 > max_level then
					max_level = level2 - 1
				end
			end
	end
	end
	end
	--print("Max level:",max_level,"origin level:",origin_level)
	
	if not origin_level or (origin_level and max_level < origin_level) then
		max_level = 0
	end
	
	
	if minetest.get_node_group(origin_n, "redstone_dust") > 0 then
		data[origin_pos] = minetest.get_content_id("redstone:dust_"..max_level)
	end

	--update lower power level redstone
	--print("------------------------")
	for x=-range, range do
	for y=-range, range do
	for z=-range, range do
			if not vector.equals(pos, vector.add(pos,vector.new(x,y,z))) then
				local p_pos = area:index(pos.x+x,pos.y+y,pos.z+z)							
				local n = content_id(data[p_pos])
				
				local level2 = minetest.registered_nodes[n].power
				
				if level2 and level2 < max_level then
					if minetest.get_node_group(n, "redstone_dust") > 0 then
						--data[p_pos] = minetest.get_content_id("redstone:dust_"..max_level-1)
						minetest.after(0,function(pos,x,y,z)
							redstone.update_everything(vector.add(pos,vector.new(x,y,z)))
						end,pos,x,y,z)
					end
				end
				if level2 and max_level < level2 and origin_level ~= max_level then
					minetest.after(0,function(pos,x,y,z)
							redstone.update_everything(vector.add(pos,vector.new(x,y,z)))
						end,pos,x,y,z)
				end
			end
	end
	end
	end
	
	
	vm:set_data(data)
	vm:write_to_map()
	vm:update_map()
end




--3d plane direct neighbor
function redstone.update(pos,oldnode)

	--local old_max_level = minetest.registered_nodes[minetest.get_node(pos).name].power	
	--change to dust
	--[[
	if minetest.get_node_group(minetest.get_node(pos).name, "redstone_dust") > 0 then
		minetest.set_node(pos, {name="redstone:dust_"..max_level})
	elseif minetest.get_node_group(minetest.get_node(pos).name, "redstone_wire") > 0 then
		minetest.set_node(pos, {name="redstone:wire_"..max_level})
	end
	]]--
	
	
	--updating the other redstone
	redstone.update_everything(pos)

end

minetest.register_craftitem("redstone:dust", {
	description = "Redstone Dust",
	inventory_image = "redstone_dust_item.png",
	wield_image = "redstone_dust_item.png",
	wield_scale = {x = 1, y = 1, z = 1 + 1/16},
	liquids_pointable = false,
	on_place = function(itemstack, placer, pointed_thing)
		if not pointed_thing.type == "node" then
			return
		end
		local pos = pointed_thing.above
		if minetest.registered_nodes[minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name].walkable and minetest.get_node(pointed_thing.above).name == "air" then
			minetest.add_node(pointed_thing.above, {name="redstone:dust_0"})
			itemstack:take_item(1)
			--print(minetest.get_node(pointed_thing.above).param1)
			minetest.after(0,function(pointed_thing)
				redstone.update(pos)
			end,pointed_thing)
			return(itemstack)
		end
	end,
})


--8 power levels 8 being the highest
local color = 0
for i = 0,8 do
	local coloring = math.floor(color)
	minetest.register_node("redstone:dust_"..i,{
		description = "Redstone Dust",
		wield_image = "redstone_dust_item.png",
		tiles = {
			"redstone_dust_main.png^[colorize:red:"..coloring, "redstone_turn.png^[colorize:red:"..coloring,
			"redstone_t.png^[colorize:red:"..coloring, "redstone_cross.png^[colorize:red:"..coloring
		},
		power=i,
		drawtype = "raillike",
		paramtype = "light",
		sunlight_propagates = true,
		is_ground_content = false,
		walkable = false,
		node_placement_prediction = "",
		selection_box = {
			type = "fixed",
			fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
		},
		groups={instant=1,attached=1,redstone_dust=1,redstone=1},
		drop="redstone:dust",
		on_place = function(itemstack, placer, pointed_thing)
			minetest.item_place_node(itemstack, placer, pointed_thing)
			redstone.update(pos)
		end,
		on_dig = function(pos, node, digger)
			minetest.node_dig(pos, node, digger)
			redstone.update(pos,node)
		end,
		connects_to = {"group:redstone"},
	})
	color= color +31.875
end

