function recalculate_armor(player)
    if not player or (player and not player:is_player()) then return end
    local inv = player:get_inventory()
    local meta = player:get_meta()
    local player_skin = meta:get_string("skin") 
    local armor_skin = "blank_skin.png"

    local stack = inv:get_stack("armor_head",1):get_name()
    if stack ~= "" and minetest.get_item_group(stack,"helmet") > 0 then
        local skin_element = minetest.get_itemdef(stack, "wearing_texture")
        player_skin = player_skin.."^"..skin_element
    end

    stack = inv:get_stack("armor_torso",1):get_name()
    if stack ~= "" and minetest.get_item_group(stack,"chestplate") > 0 then
        local skin_element = minetest.get_itemdef(stack, "wearing_texture")
        armor_skin = armor_skin.."^"..skin_element
    end

    stack = inv:get_stack("armor_legs",1):get_name()
    if stack ~= "" and minetest.get_item_group(stack,"leggings") > 0 then
        local skin_element = minetest.get_itemdef(stack, "wearing_texture")
        armor_skin = armor_skin.."^"..skin_element
    end

    stack = inv:get_stack("armor_feet",1):get_name()
    if stack ~= "" and minetest.get_item_group(stack,"boots") > 0 then
        local skin_element = minetest.get_itemdef(stack, "wearing_texture")
        armor_skin = armor_skin.."^"..skin_element
    end
    player:set_properties({textures = {player_skin,armor_skin}})
end

function calculate_armor_absorbtion(player)
    if not player or (player and not player:is_player()) then return end

    local inv = player:get_inventory()
    local armor_absorbtion = 0

    local stack = inv:get_stack("armor_head",1):get_name()
    if stack ~= "" then
        local level = minetest.get_item_group(stack,"armor_level")
        local defense = minetest.get_item_group(stack,"armor_defense")
        armor_absorbtion = armor_absorbtion + (level*defense)
    end

    stack = inv:get_stack("armor_torso",1):get_name()
    if stack ~= "" then
        local level = minetest.get_item_group(stack,"armor_level")
        local defense = minetest.get_item_group(stack,"armor_defense")
        armor_absorbtion = armor_absorbtion + (level*defense)
    end

    stack = inv:get_stack("armor_legs",1):get_name()
    if stack ~= "" then
        local level = minetest.get_item_group(stack,"armor_level")
        local defense = minetest.get_item_group(stack,"armor_defense")
        armor_absorbtion = armor_absorbtion + (level*defense)
    end

    stack = inv:get_stack("armor_feet",1):get_name()
    if stack ~= "" then
        local level = minetest.get_item_group(stack,"armor_level")
        local defense = minetest.get_item_group(stack,"armor_defense")
        armor_absorbtion = armor_absorbtion + (level*defense)
    end
    if armor_absorbtion > 0 then
        armor_absorbtion = math.ceil(armor_absorbtion/4)
    end
    return(armor_absorbtion)
end

function set_armor_gui(player)
    if not player or (player and not player:is_player()) then return end
    local meta  = player:get_meta()
    local level = calculate_armor_absorbtion(player)
    local hud = meta:get_int("armor_bar")
    player:hud_change(hud, "number", level)
end



function damage_armor(player,damage)
    if not player or (player and not player:is_player()) then return end

    local inv = player:get_inventory()
    
    local recalc = false

    local stack = inv:get_stack("armor_head",1)
    local name = stack:get_name()
    if name ~= "" then
        local wear_level = ((9-minetest.get_item_group(name,"armor_level"))*8)*(5-minetest.get_item_group(name,"armor_type"))*damage
        stack:add_wear(wear_level)
        inv:set_stack("armor_head", 1, stack)
        local new_stack = inv:get_stack("armor_head",1):get_name()
        if new_stack == "" then
            recalc = true
        end
    end

    stack = inv:get_stack("armor_torso",1)
    name = stack:get_name()
    if name ~= "" then
        local wear_level = ((9-minetest.get_item_group(name,"armor_level"))*4)*(5-minetest.get_item_group(name,"armor_type"))*damage
        stack:add_wear(wear_level)
        inv:set_stack("armor_torso", 1, stack)
        local new_stack = inv:get_stack("armor_torso",1):get_name()
        if new_stack == "" then
            recalc = true
        end
    end

    stack = inv:get_stack("armor_legs",1)
    name = stack:get_name()
    if name ~= "" then
        local wear_level = ((9-minetest.get_item_group(name,"armor_level"))*6)*(5-minetest.get_item_group(name,"armor_type"))*damage
        stack:add_wear(wear_level)
        inv:set_stack("armor_legs", 1, stack)
        local new_stack = inv:get_stack("armor_legs",1):get_name()
        if new_stack == "" then
            recalc = true
        end
    end

    stack = inv:get_stack("armor_feet",1)
    name = stack:get_name()
    if name ~= "" then
        local wear_level = ((9-minetest.get_item_group(name,"armor_level"))*10)*(5-minetest.get_item_group(name,"armor_type"))*damage
        stack:add_wear(wear_level)
        inv:set_stack("armor_feet", 1, stack)
        local new_stack = inv:get_stack("armor_feet",1):get_name()
        if new_stack == "" then
            recalc = true
        end
    end

    if recalc == true then
        minetest.sound_play("armor_break",{to_player=player:get_player_name(),gain=1,pitch=math.random(80,100)/100})
        recalculate_armor(player)
        set_armor_gui(player)
        --do particles too
    end
end


minetest.register_on_joinplayer(function(player)
    local meta = player:get_meta()
	player:hud_add({
		hud_elem_type = "statbar",
		position = {x = 0.5, y = 1},
		text = "armor_icon_bg.png",
		number = 20,
		--direction = 1,
		size = {x = 24, y = 24},
		offset = {x = (-10 * 24) - 25, y = -(48 + 50 + 39)},
	})
	local armor_bar = player:hud_add({
		hud_elem_type = "statbar",
		position = {x = 0.5, y = 1},
		text = "armor_icon.png",
		number = calculate_armor_absorbtion(player),--meta:get_int("hunger"),
		--direction = 1,
		size = {x = 24, y = 24},
		offset = {x = (-10 * 24) - 25, y = -(48 + 50 + 39)},
	})
    meta:set_int("armor_bar", armor_bar)
    
    local inv = player:get_inventory()
    inv:set_size("armor_head" ,1)
    inv:set_size("armor_torso",1)
    inv:set_size("armor_legs" ,1)
    inv:set_size("armor_feet" ,1)

    minetest.after(0.1,function()
        recalculate_armor(player)
    end)
end)

minetest.register_on_dieplayer(function(player)
    set_armor_gui(player)
end)

minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
    if inventory_info.from_list == "armor_head" or inventory_info.from_list == "armor_torso" or inventory_info.from_list == "armor_legs" or inventory_info.from_list == "armor_feet" or
       inventory_info.to_list   == "armor_head" or inventory_info.to_list   == "armor_torso" or inventory_info.to_list   == "armor_legs" or inventory_info.to_list   == "armor_feet" then
        minetest.after(0,function()
            recalculate_armor(player)
            set_armor_gui(player)
        end)
    end
end)

--only allow players to put armor in the right slots to stop exploiting chestplates
minetest.register_allow_player_inventory_action(function(player, action, inventory, inventory_info)
    if inventory_info.to_list == "armor_head" then
        local stack = inventory:get_stack(inventory_info.from_list,inventory_info.from_index)
        local item = stack:get_name()
        if minetest.get_item_group(item, "helmet") == 0 then
            return(0)
        end
    elseif inventory_info.to_list == "armor_torso" then
        local stack = inventory:get_stack(inventory_info.from_list,inventory_info.from_index)
        local item = stack:get_name()
        if minetest.get_item_group(item, "chestplate") == 0 then
            return(0)
        end
    elseif inventory_info.to_list == "armor_legs" then
        local stack = inventory:get_stack(inventory_info.from_list,inventory_info.from_index)
        local item = stack:get_name()
        if minetest.get_item_group(item, "leggings") == 0 then
            return(0)
        end
    elseif inventory_info.to_list == "armor_feet" then
        local stack = inventory:get_stack(inventory_info.from_list,inventory_info.from_index)
        local item = stack:get_name()
        if minetest.get_item_group(item, "boots") == 0 then
            return(0)
        end
    end
end)

local materials = {["iron"]=4,["chain"]=6,["gold"]=2,["diamond"]=8} --max 8
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