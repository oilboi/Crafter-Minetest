--[[
might have to calculate this in a local memory table then set the nodes using a voxelmanip
]]--



---set a torch source



local path = minetest.get_modpath("redstone")
dofile(path.."/wire.lua")
dofile(path.."/torch.lua")

redstone = {}

local r_index = {}

--collect all nodes that are local to the modified
--node of redstone dust and store in memory
function redstone.collect_info(pos)
	for x = -1,1 do
	for y = -1,1 do
	for z = -1,1 do
		--do not index self
		if not vector.equals(vector.new(x,y,z),vector.new(0,0,0)) then 
			local i = vector.add(pos,vector.new(x,y,z))
			--index dust
			if minetest.get_node_group(minetest.get_node(i).name, "redstone_dust") > 0 then
				--check the index
				--do not add duplicates with this methods
				local already_in = false
				for _,t in ipairs(r_index) do
					for _,tabler in ipairs(r_index) do
						if already_in == false and vector.equals(tabler,i) then
							already_in = true
						end
					end
				end
				--add if not already in
				if already_in == false then
					i.type = "dust"
					table.insert(r_index,i)
					redstone.collect_info(i)
				end
			--index power sources
			elseif minetest.get_node_group(minetest.get_node(i).name, "redstone_torch") > 0 then
				--check the index
				--do not add duplicates with this methods
				local already_in = false
				for _,t in ipairs(r_index) do
					for _,tabler in ipairs(r_index) do
						if already_in == false and vector.equals(tabler,i) then
							already_in = true
						end
					end
				end
				--add if not already in
				if already_in == false then
					i.type = "torch"
					table.insert(r_index,i)
					--redstone.collect_info(i,pos)
				end
			end
		end
	end
	end
	end
end

--check if index table contains items
--then execute an update
minetest.register_globalstep(function(dtime)
	local indexer = 0
	--check if indexes exist
	for test,test2 in pairs(r_index) do
		if test then
			indexer = indexer + 1
		end
	end
	--if indexes exist then calculate redstone
	if indexer > 0 then
		redstone.calculate()
	end
	--clear the index to avoid cpu looping wasting processing power
	r_index = {}
end)

--make all power sources push power out
function redstone.calculate()
	local temp_table = {}
	
	--create blank table for torches to navigate through
	--convert it into different style 3d array to index easier 
	--in pathfinding
	for _,i in pairs(r_index) do
		if i.type == "dust" then
			--local value = vector.new(i.x,i.y,i.z)
			--value.level = 0
			
			if not temp_table[i.x] then temp_table[i.x] = {} end
			if not temp_table[i.x][i.y] then temp_table[i.x][i.y] = {} end
			temp_table[i.x][i.y][i.z] = 0
			
		end
	end
	
	--create base power variable and table
	local power_sources = {}
	local power = false
	
	--index sources
	for _,i in pairs(r_index) do
		if i.type == "torch" then
			power = true
			table.insert(power_sources,vector.new(i.x,i.y,i.z))
		end
	end
	
	--push power out into dust
	for _,source in pairs(power_sources) do
		temp_table = redstone.pathfind(temp_table,source,9)
	end
	
	
	--reassemble the table into a position list minetest can understand
	for x,datax in pairs(temp_table) do
		for y,datay in pairs(datax) do
			for z,level in pairs(datay) do
				--print(dump(z),dump(dataz))
				minetest.set_node(vector.new(x,y,z),{name="redstone:dust_"..level})
			end
		end
	end	
end

--make redstone wire pass on current one level lower than it is
function redstone.pathfind(temp_table,source,source_level)
	--print(dump(temp_table))
	for x = -1,1 do
	for y = -1,1 do
	for z = -1,1 do
		i = vector.add(vector.new(source.x,source.y,source.z),vector.new(x,y,z))
		if temp_table and temp_table[i.x] and temp_table[i.x][i.y] and temp_table[i.x][i.y][i.z] then
			level = temp_table[i.x][i.y][i.z]
			if level < source_level then
				passed_on_level = source_level - 1
				temp_table[i.x][i.y][i.z] = passed_on_level
				if passed_on_level > 0 then
					redstone.pathfind(temp_table,i,passed_on_level)
				end
			end
		end
	end
	end
	end
	return(temp_table)
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
			--minetest.after(0,function(pointed_thing)
			--	redstone.add(pos)
			--end,pointed_thing)
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
		on_construct = function(pos)
			redstone.collect_info(pos)
		end,
		after_destruct = function(pos)
			--redstone.remove(pos,minetest.registered_nodes[minetest.get_node(pos).name].power)
			redstone.collect_info(pos)
		end,
		connects_to = {"group:redstone"},
	})
	color= color +31.875
end

