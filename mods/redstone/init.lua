--[[

redstone powder is raillike

check if solid block above
--if so, do not conduct above

uses height level to do powerlevel

uses lightlevel
a function for adding and removing redstone level

]]--



---set a torch source



local path = minetest.get_modpath("redstone")
dofile(path.."/wire.lua")
dofile(path.."/torch.lua")

redstone = {}

--3d plane direct neighbor
function redstone.update(pos,oldnode)
      local old_max_level = minetest.registered_nodes[minetest.get_node(pos).name].power
      --recover old info
      if not old_max_level then
            print("recovering")
            old_max_level = minetest.registered_nodes[oldnode.name].power
      end

      local max_level = 0
      for x = -1,1 do
      for y = -1,1 do
      for z = -1,1 do
            if math.abs(x)+math.abs(y)+math.abs(z) == 1 then
                  local pos2 = vector.add(pos,vector.new(x,y,z))
                  local level2 = minetest.registered_nodes[minetest.get_node(pos2).name].power
                  if level2 and level2 > max_level then
                        max_level = level2 - 1
                  end
            end
      end
      end
      end

      --print(max_level)
      if old_max_level and old_max_level > max_level then
            max_level = 0
      end
      --change to dust
      if minetest.get_node_group(minetest.get_node(pos).name, "redstone_dust") > 0 then
            minetest.set_node(pos, {name="redstone:dust_"..max_level})
      end

      for x = -1,1 do
      for y = -1,1 do
      for z = -1,1 do
            if math.abs(x)+math.abs(y)+math.abs(z) == 1 then
                  local pos2 = vector.add(pos,vector.new(x,y,z))
                  local level2 = minetest.registered_nodes[minetest.get_node(pos2).name].power
                  if level2 and (level2 < max_level or level2 < old_max_level) then
                        redstone.update(pos2)
                  end
            end
      end
      end
      end
end




minetest.register_craftitem("redstone:dust", {
      description = "Redstone Dust",
      inventory_image = "redstone_dust_item.png",
      wield_image = "redstone_dust_item.png",
      wield_scale = {x = 1, y = 1, z = 1 + 1/16},
      liquids_pointable = false,
      on_place = function(itemstack, placer, pointed_thing)
            if not pointed_thing.type == "node" then
                  return
            end
            local pos = pointed_thing.above
            if minetest.registered_nodes[minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name].walkable and minetest.get_node(pointed_thing.above).name == "air" then
                  minetest.add_node(pointed_thing.above, {name="redstone:dust_0"})
                  itemstack:take_item(1)
                  --print(minetest.get_node(pointed_thing.above).param1)
                  minetest.after(0,function(pointed_thing)
                        minetest.punch_node(pointed_thing.above)
                  end,pointed_thing)
                  return(itemstack)
            end
      end,
})


--8 power levels 8 being the highest
local color = 0
for i = 0,8 do
      local coloring = math.floor(color)
      minetest.register_node("redstone:dust_"..i,{
            description = "Redstone Dust",
            wield_image = "redstone_dust_item.png",
            tiles = {
                  "redstone_dust_main.png^[colorize:red:"..coloring, "redstone_turn.png^[colorize:red:"..coloring,
                  "redstone_t.png^[colorize:red:"..coloring, "redstone_cross.png^[colorize:red:"..coloring
            },
            power=i,
            drawtype = "raillike",
            paramtype = "light",
            sunlight_propagates = true,
            is_ground_content = false,
            walkable = false,
            node_placement_prediction = "",
            selection_box = {
                  type = "fixed",
                  fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
            },
            groups={instant=1,attached=1,redstone_dust=1,redstone=1},
            drop="redstone:dust",
            on_punch = function(pos, node, puncher, pointed_thing)
                  redstone.update(pos)
            end,
            on_dig = function(pos, node, digger)
                  minetest.node_dig(pos, node, digger)
                  redstone.update(pos,node)
            end,
      })
      color= color +31.875
end

