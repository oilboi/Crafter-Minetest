function recalculate_armor(player)
    if not player or (player and not player:is_player()) then return end
    local inv = player:get_inventory()
    local meta = player:get_meta()
    local player_skin = meta:get_string("skin") 
    local armor_skin = "blank_skin.png"

    local stack = inv:get_stack("armor_head",1):get_name()
    stack = stack:gsub("_item.png","")
    stack = stack:gsub("armor:","")
    if stack ~= "" then
        player_skin = player_skin.."^"..stack..".png"
    end

    stack = inv:get_stack("armor_torso",1):get_name()
    stack = stack:gsub("_item.png","")
    stack = stack:gsub("armor:","")
    if stack ~= "" then
        armor_skin = armor_skin.."^"..stack..".png"
    end

    stack = inv:get_stack("armor_legs",1):get_name()
    stack = stack:gsub("_item.png","")
    stack = stack:gsub("armor:","")
    if stack ~= "" then
        armor_skin = armor_skin.."^"..stack..".png"
    end

    stack = inv:get_stack("armor_feet",1):get_name()
    stack = stack:gsub("_item.png","")
    stack = stack:gsub("armor:","")
    if stack ~= "" then
        armor_skin = armor_skin.."^"..stack..".png"
    end
    player:set_properties({textures = {player_skin,armor_skin}})
end


minetest.register_on_joinplayer(function(player)
    local inv = player:get_inventory()

    inv:set_size("armor_head" ,1)
    inv:set_size("armor_torso",1)
    inv:set_size("armor_legs" ,1)
    inv:set_size("armor_feet" ,1)

    minetest.after(0.1,function()
        recalculate_armor(player)
    end)
end)

minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
    if inventory_info.from_list == "armor_head" or inventory_info.from_list == "armor_torso" or inventory_info.from_list == "armor_legs" or inventory_info.from_list == "armor_feet" or
       inventory_info.to_list   == "armor_head" or inventory_info.to_list   == "armor_torso" or inventory_info.to_list   == "armor_legs" or inventory_info.to_list   == "armor_feet" then
        minetest.after(0,function()
            recalculate_armor(player)
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

local armor_type = {["helmet"]=2,["chestplate"]=5,["leggings"]=3,["boots"]=2}
local materials = {["iron"]=2,["chain"]=4,["gold"]=3,["diamond"]=7}

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
        end
        
    end
end