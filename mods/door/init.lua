--this is a really lazy way to make a door and I'll improve it in the future
for _,material in pairs({"wood","iron"}) do
--this is the function that makes the door open and close when rightclicked
local door_rightclick = function(pos)
	local node = minetest.get_node(pos)
	local name = node.name
	local opened = minetest.get_item_group(name, "door_open")
	local closed = minetest.get_item_group(name, "door_closed")
	local closed = minetest.get_item_group(name, "door_closed")
	local top = minetest.get_item_group(name, "top")
	local bottom = minetest.get_item_group(name, "bottom")
	local param2 = node.param2
	local pos2 = table.copy(pos)
	
	--close the door
	if opened > 0 then
		minetest.sound_play("door_close", {pos=pos,pitch=math.random(80,100)/100})
		if top > 0 then
			pos2.y = pos2.y - 1
			minetest.set_node(pos,{name="door:top_"..material.."_closed",param2=param2})
			minetest.set_node(pos2,{name="door:bottom_"..material.."_closed",param2=param2})
		elseif bottom > 0 then
			pos2.y = pos2.y + 1
			minetest.set_node(pos,{name="door:bottom_"..material.."_closed",param2=param2})
			minetest.set_node(pos2,{name="door:top_"..material.."_closed",param2=param2})
		end
	--open the door
	elseif closed > 0 then
		minetest.sound_play("door_open", {pos=pos,pitch=math.random(80,100)/100})
		if top > 0 then
			pos2.y = pos2.y - 1
			minetest.set_node(pos,{name="door:top_"..material.."_open",param2=param2})
			minetest.set_node(pos2,{name="door:bottom_"..material.."_open",param2=param2})
		elseif bottom > 0 then
			pos2.y = pos2.y + 1
			minetest.set_node(pos,{name="door:bottom_"..material.."_open",param2=param2})
			minetest.set_node(pos2,{name="door:top_"..material.."_open",param2=param2})
		end
	end
end

--this is where the top and bottom of the door are created
for _,door in pairs({"top","bottom"}) do
		for _,state in pairs({"open","closed"}) do
			local door_node_box = {}
			if state == "closed" then
				door_node_box = {-0.5, -0.5,  -0.5, 0.5,  0.5, -0.3}
			elseif state == "open" then
				door_node_box = {5/16, -0.5,  -0.5, 0.5,  0.5, 0.5}
			end
		
			local tiles
			local groups
			local sounds
			local on_rightclick
			local redstone_deactivation
			local redstone_activation
			--make it so only the bottom activates
			
			if material == "wood" then
				sounds = main.woodSound()
				on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
					door_rightclick(pos)
				end
				--bottom
				if door == "bottom" then
					tiles = {"wood.png"}
					groups = {wood = 2, tree = 1, hard = 1, axe = 1, hand = 3, redstone_activation = 1,bottom = 1,door_open = ((state == "open" and 1) or 0),door_closed = ((state == "closed" and 1) or 0)}
					--redstone input
					if state == "open" then
						redstone_deactivation = function(pos)
							door_rightclick(pos)
						end
					elseif state == "closed" then
						redstone_activation = function(pos)
							door_rightclick(pos)
						end
					end
				--top
				else
					if state == "closed" then
						tiles = {"wood.png","wood.png","wood.png","wood.png","wood_door_top.png","wood_door_top.png"}
					elseif state == "open" then
						tiles = {"wood.png","wood.png","wood_door_top.png","wood_door_top.png","wood.png","wood.png"}
					end
					groups = {wood = 2, tree = 1, hard = 1, axe = 1, hand = 3,top = 1,door_open = ((state == "open" and 1) or 0),door_closed = ((state == "closed" and 1) or 0)}
				end
			elseif material == "iron" then
				sounds = main.stoneSound()
				
				
				
				if door == "bottom" then
					tiles = {"iron_block.png"}
					groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4, redstone_activation = 1,bottom = 1,door_open = ((state == "open" and 1) or 0),door_closed = ((state == "closed" and 1) or 0)}
					--redstone input
					if state == "open" then
						redstone_deactivation = function(pos)
							door_rightclick(pos)
						end
					elseif state == "closed" then
						redstone_activation = function(pos)
							door_rightclick(pos)
						end
					end
				else
					if state == "closed" then
						tiles = {"iron_block.png","iron_block.png","iron_block.png","iron_block.png","iron_door_top.png","iron_door_top.png"}
					elseif state == "open" then
						tiles = {"iron_block.png","iron_block.png","iron_door_top.png","iron_door_top.png","iron_block.png","iron_block.png"}
					end
					
					
					groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,top = 1,door_open = ((state == "open" and 1) or 0),door_closed = ((state == "closed" and 1) or 0)}
				end
			end
			minetest.register_node("door:"..door.."_"..material.."_"..state, {
				description = material:gsub("^%l", string.upper).." Door",
				tiles = tiles,
				wield_image = "door_inv_"..material..".png",
				inventory_image = "door_inv_"..material..".png",
				drawtype = "nodebox",
				paramtype = "light",
				paramtype2 = "facedir",
				groups = groups,
				sounds = sounds,
				drop = "door:bottom_"..material.."_closed",
				node_placement_prediction = "",
				node_box = {
					type = "fixed",
					fixed = {
							--left front bottom right back top
							door_node_box
						},
					},
				--redstone activation is in both because only the bottom is defined as an activator and it's easier to do it like this
				redstone_activation = redstone_activation,
				redstone_deactivation = redstone_deactivation,
				on_rightclick = on_rightclick,
				after_place_node = function(pos, placer, itemstack, pointed_thing)
					local node = minetest.get_node(pos)
					local param2 = node.param2
					local pos2 = table.copy(pos)
					pos2.y = pos2.y + 1
					if minetest.get_node(pos2).name == "air" then
						minetest.set_node(pos2,{name="door:top_"..material.."_closed",param2=param2})
					else
						minetest.remove_node(pos)
						itemstack:add_item(ItemStack("door:bottom_"..material.."_closed"))
					end
				end,	
				after_dig_node = function(pos, oldnode, oldmetadata, digger)
					if string.match(oldnode.name, ":bottom") then
						pos.y = pos.y + 1
						minetest.remove_node(pos)
					else
						pos.y = pos.y - 1
						minetest.remove_node(pos)
					end
				end,
			})
		end
	end
minetest.register_craft({
	output = "door:bottom_"..material.."_closed",
	recipe = {
		{"main:"..material,"main:"..material},
		{"main:"..material,"main:"..material},
		{"main:"..material,"main:"..material}
	}
})
end



