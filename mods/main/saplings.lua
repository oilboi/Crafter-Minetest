--saplings
minetest.register_node("main:sapling", {
      description = "Sapling",
      drawtype = "plantlike",
      waving = 1,
      walkable = false,
      climbable = false,
      paramtype = "light",
      is_ground_content = false,      
      tiles = {"sapling.png"},
      groups = {leaves = 1, plant = 1, axe = 1, hand = 0,instant=1, sapling=1, attached_node=1},
      sounds = main.grassSound(),
      drop = "main:sapling",
      node_placement_prediction = "",
      selection_box = {
		type = "fixed",
		fixed = {-4 / 16, -0.5, -4 / 16, 4 / 16, 7 / 16, 4 / 16}
	},
      on_place = function(itemstack, placer, pointed_thing)
            if not pointed_thing.type == "node" then
                  return
            end
            local pos = pointed_thing.above
            if minetest.get_node_group(minetest.get_node(vector.new(pos.x,pos.y-1,pos.z)).name, "soil") > 0 and minetest.get_node(pointed_thing.above).name == "air" then
                  minetest.set_node(pointed_thing.above, {name="main:sapling"})
                  minetest.sound_play("leaves",{pos=pointed_thing.above})
                  itemstack:take_item(1)
                  --print(minetest.get_node(pointed_thing.above).param1)
                  return(itemstack)
            end
      end,
})

--make sapling grow
local function sapling_grow(pos)
      if minetest.get_node_light(pos, nil) < 10 then
            --print("failed to grow at "..dump(pos))
            return
      end
      --print("growing at "..dump(pos))
      if minetest.get_node_group(minetest.get_node(vector.new(pos.x,pos.y-1,pos.z)).name, "soil") > 0 then
            local good_to_grow = true
            --check if room to grow (leaves or air)
            for i = 1,4 do
                  local node_name = minetest.get_node(vector.new(pos.x,pos.y+i,pos.z)).name
                  if node_name ~= "air" and node_name ~= "main:leaves" then
                        good_to_grow = false
                  end
            end
            if good_to_grow == true then
                  minetest.set_node(pos,{name="main:tree"})
                  minetest.place_schematic(pos, treeSchematic,"0",nil,false,"place_center_x, place_center_z")
                  --override leaves
                  for i = 1,4 do
                        minetest.set_node(vector.new(pos.x,pos.y+i,pos.z),{name="main:tree"})
                  end
            end
      end
end

--growing abm for sapling
minetest.register_abm({
      label = "Tree Grow",
      nodenames = {"group:sapling"},
      neighbors = {"group:soil"},
      interval = 3,
      chance = 2000,
      action = function(pos)
            sapling_grow(pos)
      end,
})
