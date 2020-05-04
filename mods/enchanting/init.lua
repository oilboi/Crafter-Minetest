--[[
swiftness - how fast you mine
hardness - allows the tool to go way above it's level
durable - makes the tool last longer
slippery - you drop the tool randomly
careful - "not silk touch"
fortune - drops extra items and experience
autorepair - tool will repair itself randomly
spiky - the tool will randomly hurt you when used
sharpness - the tool does more damage
]]--
local enchantment_list = {"swiftness", "durable", "slippery", "careful", "fortune", "autorepair", "spiky", "sharpness"}

local temp_names = {"Monster", "Behemoth", "Ultra", "Wow!", "Oh Em Gee", "The Ultimatum", "Holy Moly!", "Infinity"}

local hexer = {"a","b","c","d","e","f","1","2","3","4","5","6","7","8","9","0"}
minetest.register_node("enchanting:table", {
	description = "Enchanting Table",
	tiles = {"bedrock.png"},
	groups = {wood = 1, pathable = 1},
	sounds = main.stoneSound(),
	is_ground_content = false,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		minetest.after(0,function(clicker)
			local stack = clicker:get_wielded_item()
			
			local meta = stack:get_meta()
			
			if meta:get_string("enchanted") == "true" then return end
			
			if not minetest.registered_tools[itemstack:get_name()] then return end
			
			local tool_caps = itemstack:get_tool_capabilities()
			local groupcaps = tool_caps.groupcaps
			
			if not groupcaps then return end
			
			local able_enchantments = table.copy(enchantment_list)
			local player_meta = clicker:get_meta()
			local player_level = player_meta:get_int("experience_level")
			
			local enchants_available = math.floor(player_level/5)
			if enchants_available <= 0 then return end
			
			local description = minetest.registered_tools[stack:get_name()].description--temp_names[math.random(1,table.getn(temp_names))]
			for i = 1,enchants_available do
				local new_enchant = enchantment_list[math.random(1,table.getn(enchantment_list))]
				local level = math.random(1,6)
				if meta:get_int(new_enchant) == 0 then
					player_level = player_level - 5
					meta:set_int(new_enchant, level)
					description = description.."\n"..new_enchant:gsub("^%l", string.upper)..": "..tostring(level)
					if new_enchant == "swiftness" then
						for index,table in pairs(groupcaps) do
							for index2,time in pairs(table.times) do
								tool_caps["groupcaps"][index]["times"][index2] = time/(level+1)
							end
						end
					end
					if new_enchant == "durable" then
						for index,table in pairs(groupcaps) do
							tool_caps["groupcaps"][index]["uses"] = table.uses*(level+1)
						end
					end
					
					if new_enchant == "sharpness" then
						for index,data in pairs(tool_caps.damage_groups) do
							tool_caps.damage_groups[index] = data*(level+1)
						end
					end
				end
			end
			
			meta:set_string("description", description)
			meta:set_string("enchanted", "true")
			meta:set_tool_capabilities(tool_caps)
			
			player_meta:set_int("experience_level", player_level)
			
			local hud_fg_id = player_meta:get_int("experience_level_fg")
			local hud_bg_id = player_meta:get_int("experience_level_bg")
			
			clicker:hud_change(hud_bg_id, "text", tostring(player_level))
			clicker:hud_change(hud_fg_id, "text", tostring(player_level))
			
			--create truly random hex
			local colorstring = "#"
			for i = 1,6 do
				colorstring = colorstring..hexer[math.random(1,16)]
			end
			stack = minetest.itemstring_with_color(stack, colorstring)
			clicker:set_wielded_item(stack)
		end,clicker)
	end
}) 


minetest.register_craft({
	output = "enchanting:table",
	recipe = {
		{"nether:obsidian", "nether:obsidian", "nether:obsidian"},
		{"nether:obsidian", "main:diamond", "nether:obsidian"},
		{"nether:obsidian", "nether:obsidian", "nether:obsidian"},
	},
})
