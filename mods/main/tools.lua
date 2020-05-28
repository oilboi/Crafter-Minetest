--Quick definition of tools
local tool = {"shovel","axe","pick"}
local material = {"wood","stone","iron","gold","diamond"}
local sword_durability ={52,131,250,32,1561}

for level_id,material in pairs(material) do
	for id,tool in pairs(tool) do

		--print(id,tool,level,material)
		local groupcaps
		local damage
		local wear
		--shovel
		if tool == "shovel" then
			if material == "wood" then
				groupcaps2={
					dirt =  {times={[1]=0.4,[2]=1.5,[3]=3,[4]=6,[5]=12},    uses=59, maxlevel=1},
					snow =  {times={[1]=0.4,[2]=1.5,[3]=3,[4]=6,[5]=12},    uses=59, maxlevel=1},
					grass = {times={[1]=0.45,[2]=1.5,[3]=3,[4]=6,[5]=12},   uses=59, maxlevel=1},
					sand =  {times={[1]=0.4,[2]=1.5,[3]=3,[4]=6,[5]=12},    uses=59, maxlevel=1},
				}
				damage = 2.5
				wear = 500
			elseif material == "stone" then
				groupcaps2={
					dirt =  {times={[1]=0.2,[2]=0.2,[3]=1.5,[4]=3,[5]=6},   uses=131, maxlevel=1},
					snow =  {times={[1]=0.2,[2]=0.2,[3]=1.5,[4]=3,[5]=6},   uses=131, maxlevel=1},
					grass = {times={[1]=0.25,[2]=0.25,[3]=1.5,[4]=3,[5]=6}, uses=131, maxlevel=1},
					sand =  {times={[1]=0.2,[2]=0.2,[3]=1.5,[4]=3,[5]=6},   uses=131, maxlevel=1},
				}
				damage = 3.5
				wear = 400
			elseif material == "iron" then
				groupcaps2={
					dirt =  {times={[1]=0.15,[2]=0.15,[3]=0.15,[4]=1.5,[5]=3}, uses=250, maxlevel=1},
					snow =  {times={[1]=0.15,[2]=0.15,[3]=0.15,[4]=1.5,[5]=3}, uses=250, maxlevel=1},
					grass = {times={[1]=0.15,[2]=0.15,[3]=0.15,[4]=1.5,[5]=3}, uses=250, maxlevel=1},
					sand =  {times={[1]=0.15,[2]=0.15,[3]=0.15,[4]=1.5,[5]=3}, uses=250, maxlevel=1},
				}
				damage = 4.5
				wear = 300
			elseif material == "gold" then
				groupcaps2={
					dirt =  {times={[1]=0.1,[2]=0.1,[3]=0.1,[4]=0.1,[5]=1.5}, uses=32, maxlevel=1},
					snow =  {times={[1]=0.1,[2]=0.1,[3]=0.1,[4]=0.1,[5]=1.5}, uses=32, maxlevel=1},
					grass = {times={[1]=0.1,[2]=0.1,[3]=0.1,[4]=0.1,[5]=1.5}, uses=32, maxlevel=1},
					sand =  {times={[1]=0.1,[2]=0.1,[3]=0.1,[4]=0.1,[5]=1.5}, uses=32, maxlevel=1},
				}
				damage = 2.5
				wear = 1000
			elseif material == "diamond" then
				groupcaps2={
					dirt =  {times={[1]= 0.1,[2]=0.1,[3]=0.1,[4]=0.1,[5]=1.5},     uses=1561, maxlevel=1},
					snow =  {times={[1]= 0.1,[2]=0.1,[3]=0.1,[4]=0.1,[5]=1.5},     uses=1561, maxlevel=1},
					grass = {times={[1]= 0.15,[2]=0.15,[3]=0.15,[4]=0.15,[5]=1.5}, uses=1561, maxlevel=1},
					sand =  {times={[1]= 0.1,[2]=0.1,[3]=0.1,[4]=0.1,[5]=1.5},     uses=1561, maxlevel=1},
				}
				damage = 5.5
				wear = 100
			end
		end		
		--axe
		if tool == "axe" then
			if material == "wood" then
				groupcaps2={
					wood = {times={[1]=1.5,[2]=3,[3]=6,[4]=9,[5]=12}, uses=59, maxlevel=1}
				}
				damage = 7
				wear = 500
			elseif material == "stone" then
				groupcaps2={
					wood = {times={[1]=0.75,[2]=0.75,[3]=3,[4]=6,[5]=9}, uses=131, maxlevel=1}
				}
				damage=9
				wear = 400
			elseif material == "iron" then
				groupcaps2={
					wood = {times={[1]=0.5,[2]=0.5,[3]=0.5,[4]=3,[5]=6}, uses=250, maxlevel=1}
				}
				damage = 9
				wear = 300
			elseif material == "gold" then
				groupcaps2={
					wood = {times={[1]=0.25,[2]=0.25,[3]=0.25,[4]=0.25,[5]=3}, uses=32, maxlevel=1}
				}
				damage = 7
				wear = 1000
			elseif material == "diamond" then
				groupcaps2={
					wood = {times={[1]= 0.4,[2]=0.4,[3]=0.4,[4]=0.4,[5]=3}, uses=1561, maxlevel=1}
				}
				damage = 9
				wear = 100
			end
		end		
		--pickaxe
		if tool == "pick" then
			if material == "wood" then
				groupcaps2={
					--ore hardness
					--1 stone, 1 coal, 2 iron, 3 gold, 4 diamond, 5 obsidian
					stone = {times={[1]=1.15,[2]=16,[3]=32,[4]=64,[5]=128}, uses=59, maxlevel=1},
					glass = {times={[1]=0.575,[2]=16,[3]=32,[4]=64,[5]=128}, uses=59, maxlevel=1},
					netherrack = {times={[1]=0.2875,[2]=16,[3]=32,[4]=64,[5]=128}, uses=59, maxlevel=1},
				}
				damage = 3
				wear = 500
			elseif material == "stone" then
				groupcaps2={
					stone = {times={[1]=0.6,[2]=0.6,[3]=32,[4]=64,[5]=128}, uses=131, maxlevel=1},
					glass = {times={[1]=0.3,[2]=0.3,[3]=32,[4]=64,[5]=128}, uses=131, maxlevel=1},
					netherrack = {times={[1]=0.15,[2]=0.15,[3]=32,[4]=64,[5]=128}, uses=131, maxlevel=1},
				}
				damage=4
				wear = 400
			elseif material == "iron" then
				groupcaps2={
					stone = {times={[1]=0.4,[2]=0.4,[3]=0.4,[4]=32,[5]=64}, uses=250, maxlevel=1},
					glass = {times={[1]=0.2,[2]=0.2,[3]=0.2,[4]=32,[5]=64}, uses=250, maxlevel=1},
					netherrack = {times={[1]=0.1,[2]=0.1,[3]=0.1,[4]=32,[5]=64}, uses=250, maxlevel=1},
				}
				damage = 5
				wear = 300
			elseif material == "gold" then
				groupcaps2={
					stone = {times={[1]=0.2,[2]=0.2,[3]=0.2,[4]=0.2,[5]=32}, uses=32, maxlevel=1},
					glass = {times={[1]=0.1,[2]=0.1,[3]=0.1,[4]=0.1,[5]=32}, uses=32, maxlevel=1},
					netherrack = {times={[1]=0.05,[2]=0.05,[3]=0.05,[4]=0.05,[5]=32}, uses=32, maxlevel=1},
				}
				damage = 3
				wear = 1000
			elseif material == "diamond" then
				groupcaps2={
					stone = {times={[1]= 0.3,[2]=0.3,[3]=0.3,[4]=0.3,[5]=4}, uses=1561, maxlevel=1},
					glass = {times={[1]= 0.15,[2]=0.15,[3]=0.15,[4]=0.15,[5]=4}, uses=1561, maxlevel=1},
					netherrack = {times={[1]= 0.075,[2]=0.075,[3]=0.075,[4]=0.075,[5]=4}, uses=1561, maxlevel=1},
				}
				damage = 6
				wear = 100
			end
		end
		minetest.register_tool("main:"..material..tool, {
			description = material:gsub("^%l", string.upper).." "..tool:gsub("^%l", string.upper),
			inventory_image = material..tool..".png",
			tool_capabilities = {
				full_punch_interval = 0,
				--max_drop_level=0,
				groupcaps=groupcaps2,
				damage_groups = {damage=damage},
			},
			sound = {breaks = {name="tool_break",gain=0.4}}, -- change this
			groups = {flammable = 2, tool=1 },
			mob_hit_wear = wear,
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
	
	
	local wear
	
	if material == "wood" then
		damage = 4
		wear = 500
	elseif material == "stone" then
		damage = 5
		wear = 400
	elseif material == "iron" then
		damage = 6
		wear = 300
	elseif material == "gold" then
		damage = 4
		wear = 1000
	elseif material == "diamond" then
		damage = 7
		wear = 100
	end

	
	--add swords
	minetest.register_tool("main:"..material.."sword", {
		description = material:gsub("^%l", string.upper).." Sword",
		inventory_image = material.."sword.png",
		tool_capabilities = {
			full_punch_interval = 0,
			--max_drop_level=0,
			groupcaps={leaves = {times={[4]=0.7,[3]=0.7,[2]=0.7,[1]=0.7}, uses=sword_durability[level_id], maxlevel=1},},
			damage_groups = {damage = damage},
		},
		mob_hit_wear = wear,
		sound = {breaks = {name="tool_break",gain=0.4}}, -- change this
		groups = {damage=damage }
	})
end

--shears
minetest.register_tool("main:shears", {
	description = "Shears",
	inventory_image = "shears.png",
	tool_capabilities = {
		groupcaps = {
		leaves = {times={[1]= 0.05,[2]=0.05,[3]=0.05,[4]=0.05,[5]=0.05}, uses=500, maxlevel=1},
		}
	},
	sound = {breaks = "default_tool_breaks"}, -- change this
	groups = {shears = 1}
})
