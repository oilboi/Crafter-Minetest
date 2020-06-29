local minetest,vector,pairs = minetest,vector,pairs
--this is a debug for creating flat planes to test redstone
local items = {
"redstone:dust 50",
"redstone:repeater_off_0 50", 
"redstone:comparator_0 50", 
"redstone:torch 50", 
"redstone:lever_off 50", 
"redstone:button_off 50", 
"redstone:piston_off 50",
"redstone:light_off 50",
"redstone:inverter_off 50",
"redstone:player_detector_0 50"}

minetest.register_node("redstone:space", {
    description = "Stone",
    tiles = {"stone.png"},
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,pathable = 1},
    sounds = main.stoneSound(),
    after_place_node = function(pos, placer, itemstack, pointed_thing)
		local min = vector.subtract(pos,50)
		min.y = pos.y
		local max = vector.add(pos,50)
		max.y = pos.y
		local vm = minetest.get_voxel_manip()	
		local emin, emax = vm:read_from_map(min,max)
		local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
		local data = vm:get_data()
		local content_id = minetest.get_name_from_content_id
		
		local y = pos.y
		
		for x = -50,50 do
			for z = -50,50 do
				local i = vector.add(pos,vector.new(x,0,z))
				i.y = pos.y
				local p_pos = area:index(i.x,i.y,i.z)	
				data[p_pos] = minetest.get_content_id("main:stone")
			end
		end
		vm:set_data(data)
		vm:write_to_map()
		
		local placer_pos = placer:get_pos()
		placer_pos.y = pos.y + 1
		placer:move_to(placer_pos)
		
		pos.y = pos.y + 1
		for _,item in pairs(items) do
			local obj = minetest.add_item(pos,item)
			--local x=math.random(-2,2)*math.random()
			--local y=math.random(2,5)
			--local z=math.random(-2,2)*math.random()
			--if obj and obj:get_luaentity() then
			--	obj:setvelocity({x=x, y=y, z=z})
			--end
		end
    end,
    
    
})


