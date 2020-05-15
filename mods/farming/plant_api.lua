 --plant growth time contants (in seconds)
 local plant_min = 60
 local plant_max = 240
 
 minetest.register_plant = function(name,def)
	local max = 1
	 if def.stages then
		 max = def.stages
	 end
	 for i = 1,max do
		local nodename
		if def.stages then
			nodename = "farming:"..name.."_"..i
		else
			nodename = "farming:"..name
		end
	 
	 
		 local after_dig_node
		 local on_abm
		 local on_construct
		 local after_destruct
		 local after_place_node
		 --do custom functions for each node
		 --wether growing in place or up
		 if def.grows == "up" then
			 after_dig_node = function(pos, node, metadata, digger)
				if digger == nil then return end
				local np = {x = pos.x, y = pos.y + 1, z = pos.z}
				local nn = minetest.get_node(np)
				if nn.name == node.name then
					minetest.node_dig(np, nn, digger)
					minetest.sound_play("dirt",{pos=pos,gain=0.2})
				end
			end
			
			on_abm = function(pos)
				if minetest.get_node_light(pos, nil) < 10 then
					--print("failed to grow at "..dump(pos))
					return
				end
				
				local found = minetest.find_node_near(pos, 3, {"main:water","main:waterflow"})
				pos.y = pos.y - 1
				local noder = minetest.get_node(pos).name
				local found_soil = minetest.get_node_group(noder, "soil") > 0
				local found_self--[[this is deep]]= (noder == nodename)
				
				if found and (found_soil or found_self) then
					pos.y = pos.y + 2
					if minetest.get_node(pos).name == "air" then
						minetest.set_node(pos,{name="farming:"..name})
					end
				elseif not found_self then
					pos.y = pos.y + 1
					minetest.dig_node(pos)
					minetest.sound_play("dirt",{pos=pos,gain=0.2})
				end
			end
			
			after_place_node = function(pos, placer, itemstack, pointed_thing)
				pos.y = pos.y - 1
				local noder = minetest.get_node(pos).name
				local found = minetest.get_node_group(noder, "soil") > 0
				if not found then
					pos.y = pos.y + 1
					minetest.dig_node(pos)
				end
			end
			
		--for plants that grow in place
		elseif def.grows == "in_place" then
			on_abm = function(pos)
				if minetest.get_node_light(pos, nil) < 10 then
					minetest.dig_node(pos)
					minetest.sound_play("dirt",{pos=pos,gain=0.2})
					--print("failed to grow at "..dump(pos))
					return
				end
				
				pos.y = pos.y - 1
				local found = minetest.get_node_group(minetest.get_node(pos).name, "farmland") > 0
				--if found farmland below
				if found then	
					if i < max then
						pos.y = pos.y + 1
						minetest.set_node(pos,{name="farming:"..name.."_"..(i+1)})
					end
				--if not found farmland
				else
					minetest.dig_node(pos)
					minetest.sound_play("dirt",{pos=pos,gain=0.2})
				end
			end
			after_place_node = function(pos, placer, itemstack, pointed_thing)
				pos.y = pos.y - 1
				local noder = minetest.get_node(pos).name
				local found = minetest.get_node_group(noder, "farmland") > 0
				if not found then
					pos.y = pos.y + 1
					minetest.dig_node(pos)
				end
			end
		elseif def.grows == "in_place_yields" then
			on_abm = function(pos)
				if minetest.get_node_light(pos, nil) < 10 then
					minetest.dig_node(pos)
					minetest.sound_play("dirt",{pos=pos,gain=0.2})
					--print("failed to grow at "..dump(pos))
					return
				end
				pos.y = pos.y - 1
				local found = minetest.get_node_group(minetest.get_node(pos).name, "farmland") > 0
				--if found farmland below
				if found then	
					if i < max then
						pos.y = pos.y + 1
						minetest.set_node(pos,{name="farming:"..name.."_"..(i+1)})
					else
						pos.y = pos.y + 1
						local found = false
						local add_node = nil
						for x = -1,1 do
							if found == false then
								for z = -1,1 do
									if math.abs(x)+math.abs(z) == 1 then
										local node_get = minetest.get_node(vector.new(pos.x-x,pos.y,pos.z-z)).name == "air"
										if node_get then
											add_node = vector.new(pos.x-x,pos.y,pos.z-z)
											found = true
										end
									end
								end
							end
						end
						
						if found == true and add_node then
							local param2 = minetest.dir_to_facedir(vector.direction(pos,add_node))
							minetest.add_node(add_node,{name=def.grown_node,param2=param2})
							
							local facedir = minetest.facedir_to_dir(param2)
							
							local inverted_facedir = vector.multiply(facedir,-1)
							minetest.set_node(vector.add(inverted_facedir,add_node), {name="farming:"..name.."_complete", param2=minetest.dir_to_facedir(facedir)})
						end
					end
				--if not found farmland
				else
					minetest.dig_node(pos)
					minetest.sound_play("dirt",{pos=pos,gain=0.2})
				end
			end
			after_place_node = function(pos, placer, itemstack, pointed_thing)
				pos.y = pos.y - 1
				local noder = minetest.get_node(pos).name
				local found = minetest.get_node_group(noder, "farmland") > 0
				if not found then
					pos.y = pos.y + 1
					minetest.dig_node(pos)
				end
			end
		end
		
		--allow plants to only drop item at max stage
		local drop
		if i == max and def.grows ~= "in_place_yields" then
			drop = def.drop
		elseif max == 1 then
			drop = def.drop
		else
			drop = ""
		end
		
		local tiles
		if max > 1 then
			tiles = {def.tiles[1].."_"..i..".png"}
		else
			tiles = def.tiles
		end
		
		def.groups.plants = 1
		
		minetest.register_node(nodename, {
			description               = def.description,
			drawtype                  = def.drawtype,
			waving                    = def.waving,
			inventory_image           = def.inventory_image,
			walkable                  = def.walkable,
			climbable                 = def.climbable,
			paramtype                 = def.paramtype,
			tiles                     = tiles,
			paramtype2                = def.paramtype2,
			buildable_to              = def.buildable_to,
			groups                    = def.groups,
			sounds                    = def.sounds,
			selection_box             = def.selection_box,
			drop                      = drop,
			sunlight_propagates       = def.sunlight_propagates,
			node_box                  = def.node_box,
			node_placement_prediction = "",
			is_ground_content         = false,
			
			--flooding function
			floodable         = true,
			on_flood = function(pos, oldnode, newnode)
				 minetest.dig_node(pos)
			end,
			
			after_dig_node   = after_dig_node,
			after_place_node = after_place_node,
			on_construct     = on_construct,
			after_destruct   = after_destruct,
		})
		if on_abm then
			minetest.register_abm({
				label = nodename.." Grow",
				nodenames = {nodename},
				neighbors = {"air"},
				interval = 6,
				chance = 250,
				catch_up = true,
				action = function(pos)
					on_abm(pos)
				end,
			})
		end
	end
	
	--create final stage for grow in place plant stems that create food
	if def.grows == "in_place_yields" then
		minetest.register_node("farming:"..name.."_complete", {
		    description         = def.stem_description,
		    tiles               = def.stem_tiles,
		    drawtype            = def.stem_drawtype,
		    walkable            = def.stem_walkable,
		    sunlight_propagates = def.stem_sunlight_propagates,
		    paramtype           = def.stem_paramtype,
		    drop                = def.stem_drop,
			groups              = def.stem_groups,
			sounds              = def.stem_sounds,
		    node_box            = def.stem_node_box,
		    selection_box       = def.stem_selection_box,
		    paramtype2          = "facedir",
		})
		minetest.register_node("farming:"..def.fruit_name, {
		    description = def.fruit_description,
		    tiles       = def.fruit_tiles,
		    groups      = def.fruit_groups,
		    sounds      = def.fruit_sounds,
		    drop        = def.fruit_drop,
		    --this is hardcoded to work no matter what
		    paramtype2  = "facedir",
		    after_destruct = function(pos,oldnode)
			    local facedir = oldnode.param2
			    facedir = minetest.facedir_to_dir(facedir)
			    local dir = vector.multiply(facedir,-1)
			    local stem_pos = vector.add(dir,pos)
			    
			    if minetest.get_node(stem_pos).name == "farming:"..name.."_complete" then
				    minetest.set_node(stem_pos, {name = "farming:"..name.."_1"})
			    end
		    end
		})
	end
	
	if def.seed_name then
		minetest.register_craftitem("farming:"..def.seed_name.."_seeds", {
			description = def.seed_description,
			inventory_image = def.seed_inventory_image,
			on_place = function(itemstack, placer, pointed_thing)
				if pointed_thing.type ~= "node" then
					return itemstack
				end
				local pointed_thing_diff = pointed_thing.above.y - pointed_thing.under.y
				
				if pointed_thing_diff < 1 then return end
				 
				if minetest.get_node(pointed_thing.above).name ~= "air" then return end
				local pb = pointed_thing.above
				if minetest.get_node_group(minetest.get_node(vector.new(pb.x,pb.y-1,pb.z)).name, "farmland") == 0 or minetest.get_node(pointed_thing.above).name ~= "air"  then
					return itemstack
				end

				local wdir = minetest.dir_to_wallmounted(vector.subtract(pointed_thing.under,pointed_thing.above))

				local fakestack = itemstack
				local retval = false

				retval = fakestack:set_name(def.seed_plants)

				if not retval then
					return itemstack
				end
				itemstack, retval = minetest.item_place(fakestack, placer, pointed_thing, wdir)
				itemstack:set_name("farming:"..def.seed_name.."_seeds")

				if retval then
					minetest.sound_play("leaves", {pos=pointed_thing.above, gain = 1.0})
				end

				return itemstack
			end
		})
	end
end
