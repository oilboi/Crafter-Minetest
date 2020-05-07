--[[
BEFORE YOU ASK WHY ARE YOU DOING THIS!

It works better and doesn't block digging with a bucket through water
]]--

local function bucket_raycast(user,type)
	local pos = user:get_pos()
	pos.y = pos.y + user:get_properties().eye_height
	local look_dir = user:get_look_dir()
	look_dir = vector.multiply(look_dir,4)
	local pos2 = vector.add(pos,look_dir)
	
	local ray = minetest.raycast(pos, pos2, false, true)		
	if ray then
		for pointed_thing in ray do
			if pointed_thing then
				return({under=pointed_thing.under,above=pointed_thing.above})
			end
		end
	end
	return(nil)
end

-- Item definitions
minetest.register_craftitem("main:bucket", {
	description = "Bucket",
	inventory_image = "bucket.png",
	stack_max = 1,
	--wield_image = "bucket.png",
	--liquids_pointable = true,
	on_place = function(itemstack, placer, pointed_thing)		
		local pos = bucket_raycast(placer)
		
		if not pos then
			return
		end
		
		local pos_under = pos.under
		
		local node = minetest.get_node(pos_under).name
	
		if node == "main:water" then
			itemstack:replace(ItemStack("main:bucket_water"))
			minetest.remove_node(pos_under)
			return(itemstack)
		elseif node == "main:lava" or node == "nether:lava" then
			itemstack:replace(ItemStack("main:bucket_lava"))
			minetest.remove_node(pos_under)
			return(itemstack)
		end
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)
		local pos = bucket_raycast(user)
		if not pos then
			return
		end
		local pos_under = pos.under
		
		local node = minetest.get_node(pos_under).name
		
		if node == "main:water" then
			itemstack:replace(ItemStack("main:bucket_water"))
			minetest.remove_node(pos_under)
			return(itemstack)
		elseif node == "main:lava" or node == "nether:lava" then
			itemstack:replace(ItemStack("main:bucket_lava"))
			minetest.remove_node(pos_under)
			return(itemstack)
		end
	end,
})


minetest.register_craftitem("main:bucket_water", {
	description = "Bucket of Water",
	inventory_image = "bucket_water.png",
	stack_max = 1,
	--liquids_pointable = false,
	on_place = function(itemstack, placer, pointed_thing)
		local pos = bucket_raycast(placer)
		
		if not pos then
			return
		end
		
		local pos_under = pos.under
		local pos_above = pos.above
		
		local node_under = minetest.get_node(pos_under).name
		local node_above = minetest.get_node(pos_above).name
		
		local buildable_under = (minetest.registered_nodes[node_under].buildable_to == true)
		local buildable_above = (minetest.registered_nodes[node_above].buildable_to == true)
		
		--set it to water
		if buildable_under == true then
			minetest.set_node(pos_under,{name="main:water"})
			itemstack:replace(ItemStack("main:bucket"))
			return(itemstack)
		elseif buildable_above then
			minetest.set_node(pos_above,{name="main:water"})
			itemstack:replace(ItemStack("main:bucket"))
			return(itemstack)
		end
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)
		local pos = bucket_raycast(user)
		
		if not pos then
			return
		end
		
		local pos_under = pos.under
		local pos_above = pos.above
		
		local node_under = minetest.get_node(pos_under).name
		local node_above = minetest.get_node(pos_above).name
		
		local buildable_under = (minetest.registered_nodes[node_under].buildable_to == true)
		local buildable_above = (minetest.registered_nodes[node_above].buildable_to == true)
		
		--set it to water
		if buildable_under == true then
			minetest.add_node(pos_under,{name="main:water"})
			itemstack:replace(ItemStack("main:bucket"))
			return(itemstack)
		elseif buildable_above then
			minetest.add_node(pos_above,{name="main:water"})
			itemstack:replace(ItemStack("main:bucket"))
			return(itemstack)
		end
	end,
})


minetest.register_craftitem("main:bucket_lava", {
	description = "Bucket of Lava",
	inventory_image = "bucket_lava.png",
	stack_max = 1,
	--liquids_pointable = false,
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.under and minetest.get_node(pointed_thing.under).name == "tnt:tnt" then
			minetest.remove_node(pointed_thing.under)
			tnt(pointed_thing.under,7)
			itemstack:replace(ItemStack("main:bucket"))
			return(itemstack)
		end
		
		local pos = bucket_raycast(placer)
		
		if not pos then
			return
		end
		
		local pos_under = pos.under
		local pos_above = pos.above
		
		local node_under = minetest.get_node(pos_under).name
		local node_above = minetest.get_node(pos_above).name
		
		local buildable_under = (minetest.registered_nodes[node_under].buildable_to == true)
		local buildable_above = (minetest.registered_nodes[node_above].buildable_to == true)
		
		--set it to lava
		if buildable_under == true then
			if pos_under.y < 20000 then
				if pos_under.y > -10033 then
					minetest.add_node(pos_under,{name="main:lava"})
				else
					minetest.add_node(pos_under,{name="nether:lava"})
				end
				itemstack:replace(ItemStack("main:bucket"))
				return(itemstack)
			end
		elseif buildable_above then
			if pos_above.y < 20000 then
				if pos_above.y > -10033 then
					minetest.add_node(pos_above,{name="main:lava"})
				else
					minetest.add_node(pos_above,{name="nether:lava"})
				end
				itemstack:replace(ItemStack("main:bucket"))
				return(itemstack)
			end
		end
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)
		local pos = bucket_raycast(user)
		
		if not pos then
			return
		end
		
		local pos_under = pos.under
		local pos_above = pos.above
		
		local node_under = minetest.get_node(pos_under).name
		local node_above = minetest.get_node(pos_above).name
		
		local buildable_under = (minetest.registered_nodes[node_under].buildable_to == true)
		local buildable_above = (minetest.registered_nodes[node_above].buildable_to == true)
		
		--set it to lava
		if buildable_under == true then
			if pos_under.y < 20000 then
				if pos_under.y > -10033 then
					minetest.add_node(pos_under,{name="main:lava"})
				else
					minetest.add_node(pos_under,{name="nether:lava"})
				end
				itemstack:replace(ItemStack("main:bucket"))
				return(itemstack)
			end
		elseif buildable_above then
			if pos_above.y < 20000 then
				if pos_above.y > -10033 then
					minetest.add_node(pos_above,{name="main:lava"})
				else
					minetest.add_node(pos_above,{name="nether:lava"})
				end
				itemstack:replace(ItemStack("main:bucket"))
				return(itemstack)
			end
		end
	end,
})
