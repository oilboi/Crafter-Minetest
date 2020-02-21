--remember to delete spawnpoint when bed removed

local mod_storage = minetest.get_mod_storage()
local time_night = {begin = 19000, ending = 5500}

--node boxes are from mineclone2
local function create_spawnpoint(pos,clicker)
      local time = minetest.get_timeofday() * 24000
      
      if time > time_night.begin or time < time_night.ending then
            local name = clicker:get_player_name()
            local string_pos = minetest.pos_to_string(pos)
            mod_storage:set_string(name, string_pos)
            minetest.chat_send_player(name, "Your respawn point has been set!")
            minetest.set_timeofday(time_night.ending/24000)
      else
            minetest.chat_send_player(clicker:get_player_name(), "You can only sleep at night!")
      end
end

--delete player spawnpoint if remove bed
local function remove_spawnpoint(pos,clicker)
      local name = clicker:get_player_name()
      local string_pos = mod_storage:get_string(name)
      if string_pos ~= "" then
            local pos2 = minetest.string_to_pos(string_pos)
            if vector.equals(pos,pos2) then
                  mod_storage:set_string(name, "")
                  minetest.chat_send_player(name, "Your respawn point has been removed!")
            end
      end
end

--try to send the player to their bed
minetest.register_on_respawnplayer(function(player)
      local name = player:get_player_name()
      local string_pos = mod_storage:get_string(name)
      if string_pos ~= "" then
            local pos = minetest.string_to_pos(string_pos)
            player:setpos(pos)
            return(true)
      end
end)
--these are beds
minetest.register_node("bed:bed", {
    description = "Bed",
    inventory_image = "bed.png",
    wield_image = "bed.png",
    paramtype2 = "facedir",
    tiles = {"bed_top.png^[transform1","wood.png","bed_side.png","bed_side.png^[transform4","bed_front.png","nothing.png"},
    groups = {wood = 1, hard = 1, axe = 1, hand = 3, instant=1},
    sounds = main.woodSound(),
    drawtype = "nodebox",
      node_placement_prediction = "",
      on_construct = function(pos)
            
            local param2 = minetest.get_node(pos).param2
            local facedir = minetest.facedir_to_dir(param2)
            
            --cancel if not air
            if minetest.get_node(vector.add(pos,facedir)).name ~= "air" then
                  minetest.remove_node(pos)
                  local obj = minetest.add_item(pos, "bed:bed")
                  return
            end
            
            
            facedir = vector.multiply(facedir,-1)
            param2 = minetest.dir_to_facedir(facedir, false)
            
            
            minetest.add_node(pos,{name="bed:bed_front", param2=param2})
                  
            facedir = vector.multiply(facedir,-1)
            minetest.add_node(vector.add(pos,facedir),{name="bed:bed_back", param2=param2})
      end,
})

minetest.register_node("bed:bed_front", {
    description = "Bed",
    paramtype = "light",
    paramtype2 = "facedir",
    tiles = {"bed_top.png^[transform1","wood.png","bed_side.png","bed_side.png^[transform4","bed_front.png","nothing.png"},
    groups = {wood = 1, hard = 1, axe = 1, hand = 3, instant=1,bouncy=50},
    sounds = main.woodSound(),
    drawtype = "nodebox",
    node_box = {
            type = "fixed",
            fixed = {
                        {-0.5, -5/16, -0.5, 0.5, 0.06, 0.5},
                        {-0.5, -0.5, 0.5, -5/16, -5/16, 5/16},
                        {0.5, -0.5, 0.5, 5/16, -5/16, 5/16},
                  },
            },
      node_placement_prediction = "",
      drop = "bed:bed",
      on_dig = function(pos, node, digger)
            local param2 = minetest.get_node(pos).param2
            local facedir = minetest.facedir_to_dir(param2)      
            facedir = vector.multiply(facedir,-1)
            local obj = minetest.add_item(pos, "bed:bed")
            minetest.remove_node(pos)
            minetest.remove_node(vector.add(pos,facedir))
            remove_spawnpoint(pos,digger)
            remove_spawnpoint(vector.add(pos,facedir),digger)
      end,
      on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
            create_spawnpoint(pos,clicker)
      end,
})

minetest.register_node("bed:bed_back", {
    description = "Bed",
    paramtype = "light",
    paramtype2 = "facedir",
    tiles = {"bed_top_end.png^[transform1","wood.png","bed_side_end.png","bed_side_end.png^[transform4","nothing.png","bed_end.png"},
    groups = {wood = 1, hard = 1, axe = 1, hand = 3, instant=1,bouncy=50},
    sounds = main.woodSound(),
    drawtype = "nodebox",
    node_placement_prediction = "",
    node_box = {
            type = "fixed",
            fixed = {
                        {-0.5, -5/16, -0.5, 0.5, 0.06, 0.5},
                        {-0.5, -0.5, -0.5, -5/16, -5/16, -5/16},
                        {0.5, -0.5, -0.5, 5/16, -5/16, -5/16},
                  },
            },
      drop = "bed:bed",
      on_dig = function(pos, node, digger)
            local param2 = minetest.get_node(pos).param2
            local facedir = minetest.facedir_to_dir(param2)      
            local obj = minetest.add_item(pos, "bed:bed")
            minetest.remove_node(pos)
            minetest.remove_node(vector.add(pos,facedir))
            remove_spawnpoint(pos,digger)
            remove_spawnpoint(vector.add(pos,facedir),digger)            
      end,
      on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
            local param2 = minetest.get_node(pos).param2
            local facedir = minetest.facedir_to_dir(param2)      
            create_spawnpoint(vector.add(pos,facedir),clicker)
      end,
})
minetest.register_craft({
      output = "bed:bed",
      recipe = {
            {"main:leaves", "main:leaves", "main:leaves"},
            {"main:wood", "main:wood", "main:wood"},
      },
})
