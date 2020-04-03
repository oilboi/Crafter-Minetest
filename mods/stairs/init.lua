--stairs - shift click to place upside down
for name,def in pairs(minetest.registered_nodes) do
	if def.drawtype == "normal" and string.match(name, "main:") then
	
		--set up fence
		local def2 = table.copy(def)
		local newname = "stairs:"..string.gsub(name, "main:", "").."_stair"
		def2.mod_origin = "stairs"
		def2.name = newname
		def2.description = def.description.." Stair"
		def2.drop = newname
		def2.paramtype = "light"
		def2.drawtype = "nodebox"
		def2.paramtype2 = "facedir"
		def2.node_placement_prediction = ""
		def2.node_box = {
			type = "fixed",
			fixed = {
			{-8/16, -8/16, -0/16, 8/16, 8/16, 8/16},
			{-8/16, -8/16, -8/16, 8/16, 0/16, 8/16},
			}
		}
		--ability to place stairs upside down
		def2.on_place = function(itemstack, placer, pointed_thing)
			local sneak = placer:get_player_control().sneak
			if sneak then
				local _,worked = minetest.item_place(ItemStack(newname.."_upsidedown"), placer, pointed_thing)
				if worked then
					itemstack:take_item()
				end
			else
				minetest.item_place(itemstack, placer, pointed_thing)
			end
			return(itemstack)
		end
		def2.groups["stairs"] = 1
		minetest.register_node(newname,def2)
		
		minetest.register_craft({
			output = newname.." 6",
			recipe = {
				{ "","",name },
				{ "",name, name},
				{ name, name,name},
			}
		})
		
		minetest.register_craft({
			output = newname.." 6",
			recipe = {
				{ name,"","" },
				{ name, name,""},
				{ name, name,name},
			}
		})
	end
end
--upside down stairs
for name,def in pairs(minetest.registered_nodes) do
	if def.drawtype == "normal" and string.match(name, "main:") then
		local def2 = table.copy(def)
		local newname = "stairs:"..string.gsub(name, "main:", "").."_stair_upsidedown"
		def2.mod_origin = "stairs"
		def2.name = newname
		def2.description = def.description.." Stair"
		def2.drop = string.gsub(newname, "_upsidedown", "")
		def2.paramtype = "light"
		def2.drawtype = "nodebox"
		def2.paramtype2 = "facedir"
		def2.node_box = {
			type = "fixed",
			fixed = {
			{-8/16, -8/16, -0/16, 8/16, 8/16, 8/16},
			{-8/16, -0/16, -8/16, 8/16, 8/16, 8/16},
			}
		}
		def2.groups["stairs"] = 1
		minetest.register_node(newname,def2)
	end
end


------------------------------------------------------- slabs

local place_slab_sound = function(pos,newnode)
	local node = minetest.registered_nodes[newnode]
	local sound = node.sounds
	local placing = ""
	if sound then
		placing = sound.placing
	end
	--only play the sound when is defined
	if type(placing) == "table" then
		minetest.sound_play(placing.name, {
			  pos = pos,
			  gain = placing.gain,
			  --pitch = math.random(60,100)/100
		})
	end
end
--slabs - shift click to place upside down
for name,def in pairs(minetest.registered_nodes) do
	if def.drawtype == "normal" and string.match(name, "main:") then
	
		--set up fence
		local def2 = table.copy(def)
		local newname = "stairs:"..string.gsub(name, "main:", "").."_slab"
		def2.mod_origin = "stairs"
		def2.name = newname
		def2.description = def.description.." Slab"
		def2.drop = newname
		def2.paramtype = "light"
		def2.drawtype = "nodebox"
		def2.node_placement_prediction = ""
		def2.node_box = {
			type = "fixed",
			fixed = {
			{-8/16, -8/16, -8/16, 8/16, 0/16, 8/16},
			}
		}
		--we're passing in the local variables newname and name into this function
		--calculating wether to turn a half slab into a full block
		def2.on_place = function(itemstack, placer, pointed_thing)
			--get all the required variables
			local sneak = placer:get_player_control().sneak
			local ydiff = pointed_thing.above.y-pointed_thing.under.y
			local node_under = minetest.get_node(pointed_thing.under).name
			local rightsideup = (newname == node_under)
			local upsidedown = (newname.."_upsidedown" == node_under)
			
			local placement_worked = false
			--upsidedown slab placement
			if sneak == true then
				local _,worked = minetest.item_place(ItemStack(newname.."_upsidedown"), placer, pointed_thing)
				if worked then
					itemstack:take_item()
					placement_worked = true
				end
			--normal placement - (back of slab) or normal node
			elseif (rightsideup and ydiff == -1) or (upsidedown and ydiff == 1) or (not rightsideup and not upsidedown) or ydiff == 0 then
				local itemstack,worked = minetest.item_place(itemstack, placer, pointed_thing)
				if worked then
					placement_worked = true
				end
			--normal slab to full slab
			elseif rightsideup and ydiff == 1 then
				place_slab_sound(pointed_thing.under,newname)
				minetest.set_node(pointed_thing.under, {name = name})
				itemstack:take_item()
				placement_worked = true
			--upsidedown slab to full slab
			elseif upsidedown and ydiff == -1 then
				place_slab_sound(pointed_thing.under,newname)
				minetest.set_node(pointed_thing.under, {name = name})
				itemstack:take_item()
				placement_worked = true
			end
			
			--try to do pointed_thing above
			if placement_worked == false then
				local node_above = minetest.get_node(pointed_thing.above).name
				local rightsideup = (newname == node_above)
				local upsidedown = (newname.."_upsidedown" == node_above)
				if rightsideup or upsidedown then
					place_slab_sound(pointed_thing.above,newname)
					minetest.set_node(pointed_thing.above, {name = name})
					itemstack:take_item()
				end
			end
			
			
			return(itemstack)
		end
		def2.groups["slabs"] = 1
		def2.groups[name]=1
		minetest.register_node(newname,def2)
		--equalize recipe 6 half slabs turn into 3 full blocks
		minetest.register_craft({
			output = newname.." 6",
			recipe = {
				{ name, name,name},
			}
		})
		minetest.register_craft({
			output = name,
			recipe = {
				{ newname},
				{ newname},
			}
		})
		
	end
end
--upside down stairs
for name,def in pairs(minetest.registered_nodes) do
	if def.drawtype == "normal" and string.match(name, "main:") then
		local def2 = table.copy(def)
		local newname = "stairs:"..string.gsub(name, "main:", "").."_slab_upsidedown"
		def2.mod_origin = "stairs"
		def2.name = newname
		def2.description = def.description.." Slab"
		def2.drop = string.gsub(newname, "_upsidedown", "")
		def2.paramtype = "light"
		def2.drawtype = "nodebox"
		def2.node_box = {
			type = "fixed",
			fixed = {
			{-8/16, -0/16, -8/16, 8/16, 8/16, 8/16},
			}
		}
		def2.groups["slabs"] = 1
		def2.groups[name]=1
		minetest.register_node(newname,def2)
	end
end
