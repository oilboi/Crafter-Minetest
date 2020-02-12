--Quick definition of tools
local tool = {"shovel","axe","pick"}
local group = {[1]="dirt",[2]="wood",[3]="stone"}
local material = {"wood","stone","iron","gold","diamond"}

for level,material in pairs(material) do
	for id,tool in pairs(tool) do

		--print(id,tool,level,material)
		local groupcaps
		if group[id] == "dirt" then
			groupcaps2={dirt = {times={[4]=4-level/2,[3]=3.5-level/2,[2]=3.0-level/2,[1]=2.8-level/2}, uses=level*20, maxlevel=level},}
		end
		if group[id] == "wood" then
			groupcaps2={wood = {times={[4]=4-level/2,[3]=3.5-level/2,[2]=3.0-level/2,[1]=2.8-level/2}, uses=level*20, maxlevel=level},}
		end
		if group[id] == "stone" then
			groupcaps2={stone = {times={[4]=4-level/2,[3]=3.5-level/2,[2]=3.0-level/2,[1]=2.8-level/2}, uses=level*20, maxlevel=level},}
		end
		minetest.register_tool("main:"..material..tool, {
			description = material:gsub("^%l", string.upper).." "..tool:gsub("^%l", string.upper),
			inventory_image = material..tool..".png",
			tool_capabilities = {
				--full_punch_interval = 1.2,
				--max_drop_level=0,
				groupcaps=groupcaps2,
				--damage_groups = {fleshy=2},
			},
			sound = {breaks = "default_tool_breaks"}, -- change this
			groups = {flammable = 2, tool=1 }
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
			damage_groups = {fleshy=3},
		},
		sound = {breaks = "default_tool_breaks"}, -- change this
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
