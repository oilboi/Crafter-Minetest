 minetest.register_plant = function(name,def)
	 max = 1
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
		 local on_timer
		 local on_construct
		 local after_destruct
		 --do custom functions for each node
		 --wether growing in place or up
		 if def.grows == "up" then
			 after_dig_node = function(pos, node, metadata, digger)
				if digger == nil then return end
				local np = {x = pos.x, y = pos.y + 1, z = pos.z}
				local nn = minetest.get_node(np)
				if nn.name == node.name then
					minetest.node_dig(np, nn, digger)
				end
			end
			
			on_timer = function(pos)
				local found = minetest.find_node_near(pos, 4, {"main:water","main:waterflow"})
				if found then
					pos.y = pos.y + 1
					if minetest.get_node(pos).name == "air" then
						minetest.set_node(pos,{name="farming:"..name})
					end
					local timer = minetest.get_node_timer(pos)
					timer:start(1)
				end
			end
			
			on_construct = function(pos)
				pos.y = pos.y - 1
				local noder = minetest.get_node(pos).name
				local found = minetest.get_node_group(noder, "soil") > 0
				print(noder)
				pos.y = pos.y + 1
				if found then
					local timer = minetest.get_node_timer(pos)
					timer:start(1)
				elseif noder ~= nodename then
					minetest.dig_node(pos)
				end
			end
			
			after_destruct = function(pos)
				pos.y = pos.y - 1
				if minetest.get_node(pos).name == nodename then
					local timer = minetest.get_node_timer(pos)
					timer:start(1)
				end
			end
		--for plants that grow in place
		elseif def.grows == "in_place" then
			on_timer = function(pos)
				pos.y = pos.y - 1
				local found = minetest.get_node_group(minetest.get_node(pos).name, "farmland") > 0
				--if found farmland below
				if found then	
					if i < max then
						pos.y = pos.y + 1
						minetest.set_node(pos,{name="farming:"..name.."_"..(i+1)})
						local timer = minetest.get_node_timer(pos)
						timer:start(1)
					end
				--if not found farmland
				else
					minetest.dig_node(pos)
				end
			end
			on_construct = function(pos)
				pos.y = pos.y - 1
				local found = minetest.get_node_group(minetest.get_node(pos).name, "farmland") > 0
				pos.y = pos.y + 1
				if found then
					local timer = minetest.get_node_timer(pos)
					timer:start(1)
				else
					minetest.dig_node(pos)
				end
			end
		end
		
		--allow plants to only drop item at max stage
		local drop
		if i == max then
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
			
			
			after_dig_node = after_dig_node,
			on_timer       = on_timer,
			on_construct   = on_construct,
			after_destruct = after_destruct,
		})
	end
end
