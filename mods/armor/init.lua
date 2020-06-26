local
minetest,math,pairs
=
minetest,math,pairs

local get_item_group = minetest.get_item_group
local get_itemdef    = minetest.get_itemdef


local ceil  = math.ceil
local random = math.random

local inv
local player_skin
local armor_skin
local stack
local skin_element
function recalculate_armor(player)
    
    if not player or (player and not player:is_player()) then return end

    inv = player:get_inventory()

    player_skin = get_skin(player)
    armor_skin = "blank_skin.png"

    stack = inv:get_stack("armor_head",1):get_name()
    if stack ~= "" and get_item_group(stack,"helmet") > 0 then
        skin_element = get_itemdef(stack, "wearing_texture")
        player_skin = player_skin.."^"..skin_element
    end

    stack = inv:get_stack("armor_torso",1):get_name()
    if stack ~= "" and get_item_group(stack,"chestplate") > 0 then
        skin_element = get_itemdef(stack, "wearing_texture")
        armor_skin = armor_skin.."^"..skin_element
    end

    stack = inv:get_stack("armor_legs",1):get_name()
    if stack ~= "" and get_item_group(stack,"leggings") > 0 then
        skin_element = get_itemdef(stack, "wearing_texture")
        armor_skin = armor_skin.."^"..skin_element
    end

    stack = inv:get_stack("armor_feet",1):get_name()
    if stack ~= "" and get_item_group(stack,"boots") > 0 then
        skin_element = get_itemdef(stack, "wearing_texture")
        armor_skin = armor_skin.."^"..skin_element
    end
    player:set_properties({textures = {player_skin,armor_skin}})
end

local inv
local armor_absorbtion
local level
local defense
local stack
function calculate_armor_absorbtion(player)
    if not player or (player and not player:is_player()) then return end

    inv = player:get_inventory()
    armor_absorbtion = 0

    stack = inv:get_stack("armor_head",1):get_name()
    if stack ~= "" then
        level = get_item_group(stack,"armor_level")
        defense = get_item_group(stack,"armor_defense")
        armor_absorbtion = armor_absorbtion + (level*defense)
    end

    stack = inv:get_stack("armor_torso",1):get_name()
    if stack ~= "" then
        level = get_item_group(stack,"armor_level")
        defense = get_item_group(stack,"armor_defense")
        armor_absorbtion = armor_absorbtion + (level*defense)
    end

    stack = inv:get_stack("armor_legs",1):get_name()
    if stack ~= "" then
        level = get_item_group(stack,"armor_level")
        defense = get_item_group(stack,"armor_defense")
        armor_absorbtion = armor_absorbtion + (level*defense)
    end

    stack = inv:get_stack("armor_feet",1):get_name()
    if stack ~= "" then
        level = get_item_group(stack,"armor_level")
        defense = get_item_group(stack,"armor_defense")
        armor_absorbtion = armor_absorbtion + (level*defense)
    end
    if armor_absorbtion > 0 then
        armor_absorbtion = ceil(armor_absorbtion/4)
    end
    return(armor_absorbtion)
end

local level
function set_armor_gui(player)
    if not player or (player and not player:is_player()) then return end
    level = calculate_armor_absorbtion(player)
    hud_manager.change_hud({
		player    =  player ,
		hud_name  = "armor_fg",
		element   = "number",
		data      =  level
	})
end


local inv
local recalc
local stack
local name
local wear_level
local new_stack

function damage_armor(player,damage)
    if not player or (player and not player:is_player()) then return end

    inv = player:get_inventory()
    
    recalc = false

    stack = inv:get_stack("armor_head",1)
    name = stack:get_name()
    if name ~= "" then
        wear_level = ((9-get_item_group(name,"armor_level"))*8)*(5-get_item_group(name,"armor_type"))*damage
        stack:add_wear(wear_level)
        inv:set_stack("armor_head", 1, stack)
        new_stack = inv:get_stack("armor_head",1):get_name()
        if new_stack == "" then
            recalc = true
        end
    end

    stack = inv:get_stack("armor_torso",1)
    name = stack:get_name()
    if name ~= "" then
        wear_level = ((9-get_item_group(name,"armor_level"))*4)*(5-get_item_group(name,"armor_type"))*damage
        stack:add_wear(wear_level)
        inv:set_stack("armor_torso", 1, stack)
        new_stack = inv:get_stack("armor_torso",1):get_name()
        if new_stack == "" then
            recalc = true
        end
    end

    stack = inv:get_stack("armor_legs",1)
    name = stack:get_name()
    if name ~= "" then
        wear_level = ((9-get_item_group(name,"armor_level"))*6)*(5-get_item_group(name,"armor_type"))*damage
        stack:add_wear(wear_level)
        inv:set_stack("armor_legs", 1, stack)
        new_stack = inv:get_stack("armor_legs",1):get_name()
        if new_stack == "" then
            recalc = true
        end
    end

    stack = inv:get_stack("armor_feet",1)
    name = stack:get_name()
    if name ~= "" then
        wear_level = ((9-get_item_group(name,"armor_level"))*10)*(5-get_item_group(name,"armor_type"))*damage
        stack:add_wear(wear_level)
        inv:set_stack("armor_feet", 1, stack)
        new_stack = inv:get_stack("armor_feet",1):get_name()
        if new_stack == "" then
            recalc = true
        end
    end

    if recalc == true then
        minetest.sound_play("armor_break",{to_player=player:get_player_name(),gain=1,pitch=random(80,100)/100})
        recalculate_armor(player)
        set_armor_gui(player)
        --do particles too
    end
end

local inv
minetest.register_on_joinplayer(function(player)
	hud_manager.add_hud(player,"armor_bg",{
		hud_elem_type = "statbar",
		position = {x = 0.5, y = 1},
		text = "armor_icon_bg.png",
		number = 20,
		size = {x = 24, y = 24},
		offset = {x = (-10 * 24) - 25, y = -(48 + 50 + 39)},
	})
	hud_manager.add_hud(player,"armor_fg",{
		hud_elem_type = "statbar",
		position = {x = 0.5, y = 1},
		text = "armor_icon.png",
		number = calculate_armor_absorbtion(player),
		size = {x = 24, y = 24},
		offset = {x = (-10 * 24) - 25, y = -(48 + 50 + 39)},
	})
    
    inv = player:get_inventory()
    inv:set_size("armor_head" ,1)
    inv:set_size("armor_torso",1)
    inv:set_size("armor_legs" ,1)
    inv:set_size("armor_feet" ,1)
end)

minetest.register_on_dieplayer(function(player)
    set_armor_gui(player)
end)

local acceptable = {
    ["armor_head"]  = true,
    ["armor_torso"] = true,
    ["armor_legs"]  = true,
    ["armor_feet"]  = true,
}
minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
    if acceptable[inventory_info.from_list] or acceptable[inventory_info.to_list] then
        minetest.after(0,function()
            recalculate_armor(player)
            set_armor_gui(player)
        end)
    end
end)

--only allow players to put armor in the right slots to stop exploiting chestplates
local stack
local item
minetest.register_allow_player_inventory_action(function(player, action, inventory, inventory_info)
    if inventory_info.to_list == "armor_head" then
        stack = inventory:get_stack(inventory_info.from_list,inventory_info.from_index)
        item = stack:get_name()
        if get_item_group(item, "helmet") == 0 then
            return(0)
        end
    elseif inventory_info.to_list == "armor_torso" then
        stack = inventory:get_stack(inventory_info.from_list,inventory_info.from_index)
        item = stack:get_name()
        if get_item_group(item, "chestplate") == 0 then
            return(0)
        end
    elseif inventory_info.to_list == "armor_legs" then
        stack = inventory:get_stack(inventory_info.from_list,inventory_info.from_index)
        item = stack:get_name()
        if get_item_group(item, "leggings") == 0 then
            return(0)
        end
    elseif inventory_info.to_list == "armor_feet" then
        stack = inventory:get_stack(inventory_info.from_list,inventory_info.from_index)
        item = stack:get_name()
        if get_item_group(item, "boots") == 0 then
            return(0)
        end
    end
end)

local materials = {["coal"]=1,["lapis"]=2,["iron"]=3,["chain"]=4,["gold"]=2,["diamond"]=5,["emerald"]=6,["sapphire"]=7,["ruby"]=8} --max 8
local armor_type = {["helmet"]=2,["chestplate"]=4,["leggings"]=3,["boots"]=1} --max 4

local function bool_int(state)
    if state == true then return(1) end
    if state == false or not state then return(0) end
end

for material_id,material in pairs(materials) do
    for armor_id,armor in pairs(armor_type) do
        --print(material_id,material,"|",armor_id,armor)
        minetest.register_tool("armor:"..material_id.."_"..armor_id,{
            description = material_id:gsub("^%l", string.upper).." "..armor_id:gsub("^%l", string.upper),
    
            groups = {
                armor         = 1,
                armor_level   = material,
                armor_defense = armor,
                helmet        = bool_int(armor_id == "helmet"),
                chestplate    = bool_int(armor_id == "chestplate"),
                leggings      = bool_int(armor_id == "leggings"),
                boots         = bool_int(armor_id == "boots"),
            },
            inventory_image = material_id.."_"..armor_id.."_item.png",
            stack_max = 1,
            wearing_texture = material_id.."_"..armor_id..".png",
            tool_capabilities = {
                full_punch_interval = 0,
                max_drop_level = 0,
                groupcaps = {
                },
                damage_groups = {

                },
                punch_attack_uses = 0,
            }
        })

        if armor_id == "helmet" then
            minetest.register_craft({
                output = "armor:"..material_id.."_"..armor_id,
                recipe = {
                    {"main:"..material_id, "main:"..material_id, "main:"..material_id},
                    {"main:"..material_id, ""                  , "main:"..material_id},
                    {""                  , ""                  , ""                  }
                }
            })
        elseif armor_id == "chestplate" then
            minetest.register_craft({
                output = "armor:"..material_id.."_"..armor_id,
                recipe = {
                    {"main:"..material_id, ""                  , "main:"..material_id},
                    {"main:"..material_id, "main:"..material_id, "main:"..material_id},
                    {"main:"..material_id, "main:"..material_id, "main:"..material_id}
                }
            })
        elseif armor_id == "leggings" then
            minetest.register_craft({
                output = "armor:"..material_id.."_"..armor_id,
                recipe = {
                    {"main:"..material_id, "main:"..material_id, "main:"..material_id},
                    {"main:"..material_id, ""                  , "main:"..material_id},
                    {"main:"..material_id, ""                  , "main:"..material_id}
                }
            })
        elseif armor_id == "boots" then
            minetest.register_craft({
                output = "armor:"..material_id.."_"..armor_id,
                recipe = {
                    {""                  , "", ""                  },
                    {"main:"..material_id, "", "main:"..material_id},
                    {"main:"..material_id, "", "main:"..material_id}
                }
            })
            minetest.register_node("armor:"..material_id.."_"..armor_id.."particletexture", {
                description = "NIL",
                tiles = {material_id.."_"..armor_id.."_item.png"},
                groups = {},
                drop = "",
                drawtype = "allfaces",
                on_construct = function(pos)
                    minetest.remove_node(pos)
                end,
            })
        end
        
    end
end