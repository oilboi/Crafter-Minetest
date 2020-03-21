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
	--if table.getn(r_index) == 0 then
		--print("-----------------------")
		--print("started indexing")
	--end
	local get_name = minetest.get_node
	local group = minetest.get_node_group
	
	local function get_group(i,gotten_group)
		return(group(get_name(i).name, gotten_group))
	end
	
	for x = -1,1 do
	for y = -1,1 do
	for z = -1,1 do
		--do not index self
		if not vector.equals(vector.new(x,y,z),vector.new(0,0,0)) then
			local r_type = ""
			local i = vector.add(pos,vector.new(x,y,z))
			local execute_collection = true
			if r_index[i.x] and r_index[i.x][i.y] then
				if r_index[i.x][i.y][i.z] then
					execute_collection = false
				end
			end
			
			if execute_collection == true then
				--index dust
				if get_group(i,"redstone_dust") > 0 then
					if not r_index[i.x] then r_index[i.x] = {} end
					if not r_index[i.x][i.y] then r_index[i.x][i.y] = {} end
					r_index[i.x][i.y][i.z] = 0
					--the data to the 3d array must be written to memory before this is executed
					--or a stack overflow occurs!!!
					redstone.collect_info(i)
				--index power sources
				elseif get_group(i,"redstone_torch") > 0 then
					if not r_index[i.x] then r_index[i.x] = {} end
					if not r_index[i.x][i.y] then r_index[i.x][i.y] = {} end
					r_index[i.x][i.y][i.z] = "torch"
				--index objects that activate
				elseif get_group(i,"redstone_activation") > 0 then
					if not r_index[i.x] then r_index[i.x] = {} end
					if not r_index[i.x][i.y] then r_index[i.x][i.y] = {} end
					r_index[i.x][i.y][i.z] = "activate"
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
	--if indexes exist then calculate redstone
	if r_index and next(r_index) then
		redstone.calculate()
	end
	--clear the index to avoid cpu looping wasting processing power
	r_index = {}
end)

--make all power sources push power out
function redstone.calculate()
	--pathfind through memory map	
	for x,index_x in pairs(r_index) do
		for y,index_y in pairs(index_x) do
			for z,data in pairs(index_y) do
				if data == "torch" then
					redstone.pathfind(vector.new(x,y,z),9)
				end
			end
		end
	end
	
	--calculate values for voxel manip
	local x_min,x_max,y_min,y_max,z_min,z_max
	for x,index_x in pairs(r_index) do
		for y,index_y in pairs(index_x) do
			for z,_ in pairs(index_y) do
				--do this because the root (x) will always come first
				if not x_min then
					x_min = x
					x_max = x
					y_min = y
					y_max = y
					z_min = z
					z_max = z
				end
				if x < x_min then x_min = x end
				if x > x_max then x_max = x end
				if y < y_min then y_min = y end
				if y > y_max then y_max = y end
				if z < z_min then z_min = z end
				if z > z_max then z_max = z end
			end
		end
	end

	local min = vector.new(x_min,y_min,z_min)
	local max = vector.new(x_max,y_max,z_max)
	local vm = minetest.get_voxel_manip()	
	local emin, emax = vm:read_from_map(min,max)
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()
	local content_id = minetest.get_name_from_content_id
	
	--reassemble the table into a position list minetest can understand
	for x,datax in pairs(r_index) do
		for y,datay in pairs(datax) do
			for z,level in pairs(datay) do
				local p_pos = area:index(x,y,z)
				--print(dump(z),dump(dataz))
				if type(level) == "number" then
					data[p_pos] = minetest.get_content_id("redstone:dust_"..level)
				elseif type(level) == "string" and level == "activate" then
					local name = content_id(data[p_pos])
					minetest.after(0,function(name,x,y,z)
						minetest.registered_nodes[name].redstone_activation(vector.new(x,y,z))
					end,name,x,y,z)
				end
			end
		end
	end
	vm:set_data(data)
	vm:write_to_map()
end

--make redstone wire pass on current one level lower than it is
function redstone.pathfind(source,source_level)
	for x = -1,1 do
	for y = -1,1 do
	for z = -1,1 do
		i = vector.add(vector.new(source.x,source.y,source.z),vector.new(x,y,z))
		if r_index and r_index[i.x] and r_index[i.x][i.y] and r_index[i.x][i.y][i.z] then
			level = r_index[i.x][i.y][i.z]
			
			--normal redstone
			if type(level) == "number" then
				if level < source_level then
					local passed_on_level = source_level - 1
					r_index[i.x][i.y][i.z] = passed_on_level
					if passed_on_level > 0 then
						redstone.pathfind(i,passed_on_level)
					end
				end
			--activators
			elseif type(level) == "string" and level == "activate" then
				local passed_on_level = source_level - 1
				if source_level > 0 then
					r_index[i.x][i.y][i.z] = "activate"
				end
			end
		end
	end
	end
	end
end












--make torches activate activators when placed
function redstone.torch_activate(pos)
	--print("test")
	for x = -1,1 do
	for y = -1,1 do
	for z = -1,1 do
		local i = vector.add(pos,vector.new(x,y,z))
		if minetest.get_node_group(minetest.get_node(i).name, "redstone_activation") > 0 then
			minetest.registered_nodes[minetest.get_node(i).name].redstone_activation(i)
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
		groups={dig_immediate=1,attached=1,redstone_dust=1,redstone=1},
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
