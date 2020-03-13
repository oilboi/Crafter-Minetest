--Quick definition of tools
local tool = {"shovel","axe","pick"}
local group = {[1]="dirt",[2]="wood",[3]="stone"}
local material = {"wood","stone","iron","gold","diamond"}

for level,material in pairs(material) do
	for id,tool in pairs(tool) do

		--print(id,tool,level,material)
		local groupcaps
		if group[id] == "dirt" then
			groupcaps2={
			dirt = {times={[4]=4-level/2,[3]=3.5-level/2,[2]=3.0-level/2,[1]=2.8-level/2}, uses=(level/2)*5, maxlevel=level},
			sand = {times={[4]=4-level/2,[3]=3.5-level/2,[2]=3.0-level/2,[1]=2.8-level/2}, uses=(level/2)*5, maxlevel=level},
			}
		end
		if group[id] == "wood" then
			groupcaps2={wood = {times={[4]=4-level/2,[3]=3.5-level/2,[2]=3.0-level/2,[1]=2.8-level/2}, uses=(level/2)*5, maxlevel=level},}
		end
		if group[id] == "stone" then
			groupcaps2={stone = {times={[4]=4-level/2,[3]=3.5-level/2,[2]=3.0-level/2,[1]=2.8-level/2}, uses=(level/2)*5, maxlevel=level},}
		end
		minetest.register_tool("main:"..material..tool, {
			description = material:gsub("^%l", string.upper).." "..tool:gsub("^%l", string.upper),
			inventory_image = material..tool..".png",
			tool_capabilities = {
				--full_punch_interval = 1.2,
				--max_drop_level=0,
				groupcaps=groupcaps2,
				damage_groups = {fleshy=1},
			},
			sound = {breaks = {name="tool_break",gain=0.4}}, -- change this
			groups = {flammable = 2, tool=1 },
			--torch rightclick - hacked in since api doesn't call on_place correctly
			on_place = function(itemstack, placer, pointed_thing)
				local inv = placer:get_inventory()
				local torch = inv:contains_item("main", "torch:torch")
				local is_air = minetest.get_node(pointed_thing.above).name == "air"
				local dir = vector.subtract(pointed_thing.under, pointed_thing.above)
				local diff = dir.y
				local noddef = minetest.registered_nodes[minetest.get_node(pointed_thing.under).name]
				local walkable = noddef.walkable
				local sneak = placer:get_player_control().sneak
				
				if not sneak and noddef.on_rightclick then
					minetest.item_place(itemstack, placer, pointed_thing)
					return
				end
				
				if torch and is_air and walkable then
					if diff == 0 then
						local param2 = minetest.dir_to_wallmounted(dir)
						minetest.set_node(pointed_thing.above, {name="torch:wall",param2=param2})
						minetest.sound_play("wood", {pos=pointed_thing.above, gain = 1.0})
					elseif diff == -1 then
						minetest.place_node(pointed_thing.above,{name="torch:floor"})
					end
					--take item
					if diff == 0 or diff == -1 then
						inv:remove_item("main", "torch:torch")
					end	
				end
			end,
		})
	end
	--add swords
	minetest.register_tool("main:"..material.."sword", {
		description = material:gsub("^%l", string.upper).." Sword",
		inventory_image = material.."sword.png",
		tool_capabilities = {
			--full_punch_interval = 1.2,
			--max_drop_level=0,
			groupcaps={leaves = {times={[4]=0.7,[3]=0.7,[2]=0.7,[1]=0.7}, uses=level*20, maxlevel=4},},
			damage_groups = {fleshy=level},
		},
		sound = {breaks = {name="tool_break",gain=0.4}}, -- change this
		groups = {weapon=1 }
	})
end

minetest.register_tool("main:shears", {
		description = "Shears",
		inventory_image = "shears.png",
		tool_capabilities = {
			--full_punch_interval = 1.2,
			--max_drop_level=0,
			groupcaps={leaves = {times={[4]=0.2,[3]=0.2,[2]=0.2,[1]=0.2}, uses=300, maxlevel=4},},
			--damage_groups = {fleshy=2},
		},
		sound = {breaks = "default_tool_breaks"}, -- change this
		groups = {shears = 1}
	})
