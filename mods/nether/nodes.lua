
minetest.register_node("nether:bedrock", {
    description = "Bedrock",
    tiles = {"bedrock.png"},
    groups = {unbreakable = 1, pathable = 1},
    sounds = main.stoneSound(),
    is_ground_content = false,
    --light_source = 14, --debugging
})


minetest.register_node("nether:netherrack", {
    description = "Netherrack",
    tiles = {"netherrack.png"},
    groups = {netherrack = 1, pathable = 1},
    sounds = main.stoneSound(),
    is_ground_content = false,
    light_source = 7,
    drop = {
			max_items = 1,
			items= {
				{
					rarity = 0,
					tools = {"main:woodpick","main:stonepick","main:ironpick","main:goldpick","main:diamondpick"},
					items = {"nether:netherrack"},
				},
				},
			},
})
minetest.register_node("nether:glowstone", {
    description = "Glowstone",
    tiles = {"glowstone.png"},
    groups = {glass = 1, pathable = 1},
    sounds = main.stoneSound({
		footstep = {name = "glass_footstep", gain = 0.4},
        dug =  {name = "break_glass", gain = 0.4},
	}),
    is_ground_content = false,
    light_source = 12,
    after_destruct = function(pos, oldnode)
		destroy_aether_portal(pos)
    end,
    drop = {
			max_items = 5,
			tools = tool_required,
			items= {
				{
					tools = {"main:ironpick","main:goldpick","main:diamondpick"},
					items = {"nether:glowstone_dust"},
				},
				{
					tools = {"main:ironpick","main:goldpick","main:diamondpick"},
					items = {"nether:glowstone_dust"},
				},
				{
					tools = {"main:ironpick","main:goldpick","main:diamondpick"},
					items = {"nether:glowstone_dust"},
				},
				{
					tools = {"main:ironpick","main:goldpick","main:diamondpick"},
					items = {"nether:glowstone_dust"},
				},
				{
					rarity = 5,
					tools = {"main:ironpick","main:goldpick","main:diamondpick"},
					items = {"nether:glowstone_dust"},
				},
			},
		}
})

minetest.register_node("nether:obsidian", {
    description = "Obsidian",
    tiles = {"obsidian.png"},
    groups = {stone = 5, pathable = 1},
    --groups = {stone = 1, pathable = 1}, --leave this here for debug
    sounds = main.stoneSound(),
    is_ground_content = false,
    after_destruct = function(pos, oldnode)
		destroy_nether_portal(pos)
    end,
    --light_source = 7,
})


minetest.register_node("nether:lava", {
	description = "Lava",
	drawtype = "liquid",
	tiles = {
		{
			name = "lava_source.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
		{
			name = "lava_source.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	paramtype = "light",
	light_source = 13,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "nether:lavaflow",
	liquid_alternative_source = "nether:lava",
	liquid_viscosity = 1,
	liquid_renewable = true,
	post_effect_color = {a = 191, r = 255, g = 64, b = 0},
	groups = {lava = 3, liquid = 2, igniter = 1,touch_hurt=2},
})

minetest.register_node("nether:lavaflow", {
	description = "Flowing Lava",
	drawtype = "flowingliquid",
	tiles = {"lava_flow.png"},
	special_tiles = {
		{
			name = "lava_flow.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.3,
			},
		},
		{
			name = "lava_flow.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.3,
			},
		},
	},
	selection_box = {
            type = "fixed",
            fixed = {
                {0, 0, 0, 0, 0, 0},
            },
        },
	paramtype = "light",
	paramtype2 = "flowingliquid",
	light_source = 13,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "nether:lavaflow",
	liquid_alternative_source = "nether:lava",
	liquid_viscosity = 1,
	liquid_renewable = true,
	post_effect_color = {a = 191, r = 255, g = 64, b = 0},
	groups = {lava = 3, liquid = 2, igniter = 1,touch_hurt=2},
})

local ores = {"redstone_","coal","iron","gold","diamond"}
local tool = {"main:woodpick","main:stonepick","main:ironpick","main:goldpick","main:diamondpick"}
for id,ore in pairs(ores) do

	if id > 1 then
		id = id - 1
	end
	local tool_required = {}
	for i = id,5 do
		table.insert(tool_required, tool[i])
	end

	

	local drops = {
			max_items = 1,
			items= {
				{
					rarity = 0,
					tools = tool_required,
					items = {"nether:"..ore.."ore"},
				},
				},
			}
	if ore == "diamond" then 
		drops = {
			max_items = 1,
			items= {
				{
					rarity = 0,
					tools = tool_required,
					items = {"main:diamond"},
				},
				},
			}
	elseif ore == "coal" then 
		drops = {
			max_items = 1,
			items= {
				{
					rarity = 0,
					tools = tool_required,
					items = {"main:coal"},
				},
				},
			}
	elseif ore == "redstone_" then
		drops = {
			max_items = 5,
			tools = tool_required,
			items= {
				{
					tools = {"main:ironpick","main:goldpick","main:diamondpick"},
					items = {"redstone:dust"},
				},
				{
					tools = {"main:ironpick","main:goldpick","main:diamondpick"},
					items = {"redstone:dust"},
				},
				{
					tools = {"main:ironpick","main:goldpick","main:diamondpick"},
					items = {"redstone:dust"},
				},
				{
					tools = {"main:ironpick","main:goldpick","main:diamondpick"},
					items = {"redstone:dust"},
				},
				{
					rarity = 5,
					tools = {"main:ironpick","main:goldpick","main:diamondpick"},
					items = {"redstone:dust"},
				},
			},
		}
	end
	
	minetest.register_node("nether:"..ore.."ore", {
		description = ore:gsub("^%l", string.upper).." Ore",
		tiles = {"netherrack.png^"..ore.."ore.png"},
		groups = {netherrack = id, pathable = 1},
		sounds = main.stoneSound(),
		light_source = 7,
		drop = drops,
		after_destruct = function(pos, oldnode)
			if math.random() > 0.95 then
				minetest.sound_play("tnt_ignite")
				minetest.after(3, function(pos)
					tnt(pos,9)
				end,pos)
			end
		end,
	})
end
