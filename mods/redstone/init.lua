--[[
might have to calculate this in a local memory table then set the nodes using a voxelmanip
]]--



---set a torch source



local path = minetest.get_modpath("redstone")
dofile(path.."/wire.lua")
dofile(path.."/torch.lua")

redstone = {}

--this is the internal check for getting the max_power 
function redstone.add(pos)
	local max = 0
	local current = 0
	
	--chargup
	for x = -1,1 do
	for y = -1,1 do
	for z = -1,1 do
		if not vector.equals(vector.new(0,0,0),vector.new(x,y,z)) then
			local pos2 = vector.add(pos,vector.new(x,y,z))
			local power = minetest.registered_nodes[minetest.get_node(pos2).name].power
			if power then
				if power > max then
					max = power
					current = max - 1
				end
			end
		end
	end
	end
	end
	
	minetest.set_node(pos,{name="redstone:dust_"..current})	
	--transfer
	for x = -1,1 do
	for y = -1,1 do
	for z = -1,1 do
		local pos2 = vector.add(pos,vector.new(x,y,z))
		local power = minetest.registered_nodes[minetest.get_node(pos2).name].power
		if power then
			if power < current then
				minetest.after(0,function(pos2)
					redstone.add(pos2)
				end,pos2)
			end
		end
	end
	end
	end
end

function redstone.remove(pos,oldpower)
	local max = 0
	
	--chargup
	for x = -1,1 do
	for y = -1,1 do
	for z = -1,1 do
		if not vector.equals(vector.new(0,0,0),vector.new(x,y,z)) then
			local pos2 = vector.add(pos,vector.new(x,y,z))
			local power = minetest.registered_nodes[minetest.get_node(pos2).name].power
			if power and power ~= 9 then
				--print(power)
				if power > max then
					max = power
				end
			end
		end
	end
	end
	end
	for x = -1,1 do
	for y = -1,1 do
	for z = -1,1 do
		if not vector.equals(vector.new(0,0,0),vector.new(x,y,z)) then
			local pos2 = vector.add(pos,vector.new(x,y,z))
			local power = minetest.registered_nodes[minetest.get_node(pos2).name].power
			if power then
				if power < oldpower then
					minetest.set_node(pos,{name="redstone:dust_0"})
					
					minetest.after(0,function(pos2)
						redstone.remove(pos2,power)
					end,pos2)
				end
			end
		end
	end
	end
	end
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
				redstone.add(pos)
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
			redstone.add(pos)
		end,
		on_dig = function(pos, node, digger)
			redstone.remove(pos,minetest.registered_nodes[minetest.get_node(pos).name].power)
			minetest.node_dig(pos, node, digger)
		end,
		connects_to = {"group:redstone"},
	})
	color= color +31.875
end

