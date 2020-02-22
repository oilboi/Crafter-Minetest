print("Initializing nodes")

minetest.register_node("main:stone", {
    description = "Stone",
    tiles = {"stone.png"},
    groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4},
    sounds = main.stoneSound(),
    drop="main:cobble",
})

local ores = {"coal","iron","gold","diamond"}
for id,ore in pairs(ores) do
      local drop = "main:"..ore.."ore"
      if ore == "diamond" then drop = "main:diamond" elseif ore == "coal" then drop = "main:coal" end
      
      minetest.register_node("main:"..ore.."ore", {
            description = ore:gsub("^%l", string.upper).." Ore",
            tiles = {"stone.png^"..ore.."ore.png"},
            groups = {stone = id, hard = id, pickaxe = 1, hand = 4},
            sounds = main.stoneSound(),
            --light_source = 14,--debugging ore spawn
            drop = drop,
      })
end

minetest.register_node("main:cobble", {
    description = "Cobblestone",
    tiles = {"cobble.png"},
    groups = {stone = 2, hard = 1, pickaxe = 2, hand = 4},
    sounds = main.stoneSound(),
})

minetest.register_node("main:dirt", {
    description = "Dirt",
    tiles = {"dirt.png"},
    groups = {dirt = 1, soft = 1, shovel = 1, hand = 1, soil=1},
    sounds = main.dirtSound(),
    paramtype = "light",
})

minetest.register_node("main:grass", {
    description = "Grass",
    tiles = {"grass.png"},
    groups = {dirt = 1, soft = 1, shovel = 1, hand = 1, soil=1},
    sounds = main.dirtSound(),
    drop="main:dirt",
})

minetest.register_node("main:sand", {
    description = "Sand",
    tiles = {"sand.png"},
    groups = {dirt = 1, sand = 1, soft = 1, shovel = 1, hand = 1, falling_node = 1},
    sounds = main.sandSound(),
})

minetest.register_node("main:tree", {
    description = "Tree",
    tiles = {"treeCore.png","treeCore.png","treeOut.png","treeOut.png","treeOut.png","treeOut.png"},
    groups = {wood = 2, tree = 1, hard = 1, axe = 1, hand = 3},
    sounds = main.woodSound(),
    --set metadata so treecapitator doesn't destroy houses
    on_place = function(itemstack, placer, pointed_thing)
            local pos = pointed_thing.above
            minetest.item_place_node(itemstack, placer, pointed_thing)
            local meta = minetest.get_meta(pos)
            meta:set_string("placed", "true")      
            return(itemstack)
      end,
      --treecapitator - move treecapitator into own file using override
      on_dig = function(pos, node, digger)
      
            --check if wielding axe?
            
            local meta = minetest.get_meta(pos)
            if not meta:contains("placed") then
                  --remove tree
                  for y = -6,6 do
                        --print(y)
                        if minetest.get_node(vector.new(pos.x,pos.y+y,pos.z)).name == "main:tree" then
                              minetest.node_dig(vector.new(pos.x,pos.y+y,pos.z), node, digger)
                        end
                  end
            else
                  minetest.node_dig(pos, node, digger)
            end      
      end
})

minetest.register_node("main:wood", {
    description = "Wood",
    tiles = {"wood.png"},
    groups = {wood = 1, hard = 1, axe = 1, hand = 3},
    sounds = main.woodSound(),
})

minetest.register_node("main:leaves", {
    description = "Leaves",
    drawtype = "allfaces_optional",
      waving = 1,
      walkable = false,
      climbable = true,
      paramtype = "light",
      is_ground_content = false,      
    tiles = {"leaves.png"},
    groups = {leaves = 1, plant = 1, axe = 1, hand = 0, leafdecay = 1},
    sounds = main.grassSound(),
    drop = {
            max_items = 1,
            items= {
             {
                  -- Only drop if using a tool whose name is identical to one
                  -- of these.
                  rarity = 10,
                  items = {"main:sapling"},
                  -- Whether all items in the dropped item list inherit the
                  -- hardware coloring palette color from the dug node.
                  -- Default is 'false'.
                  --inherit_color = true,
            },
            {
                  -- Only drop if using a tool whose name is identical to one
                  -- of these.
                  tools = {"main:shears"},
                  rarity = 2,
                  items = {"main:leaves"},
                  -- Whether all items in the dropped item list inherit the
                  -- hardware coloring palette color from the dug node.
                  -- Default is 'false'.
                  --inherit_color = true,
            },
            {
                  -- Only drop if using a tool whose name is identical to one
                  -- of these.
                  tools = {"main:shears"},
                  rarity = 2,
                  items = {"main:stick"},
                  -- Whether all items in the dropped item list inherit the
                  -- hardware coloring palette color from the dug node.
                  -- Default is 'false'.
                  --inherit_color = true,
            },
            {
                  -- Only drop if using a tool whose name is identical to one
                  -- of these.
                  tools = {"main:shears"},
                  rarity = 6,
                  items = {"main:apple"},
                  -- Whether all items in the dropped item list inherit the
                  -- hardware coloring palette color from the dug node.
                  -- Default is 'false'.
                  --inherit_color = true,
            },
            },
    },
})

minetest.register_node("main:water", {
      description = "Water Source",
      drawtype = "liquid",
      waving = 3,
      tiles = {
            {
                  name = "waterSource.png",
                  backface_culling = false,
                  animation = {
                        type = "vertical_frames",
                        aspect_w = 16,
                        aspect_h = 16,
                        length = 2.0,
                  },
            },
            {
                  name = "waterSource.png",
                  backface_culling = true,
                  animation = {
                        type = "vertical_frames",
                        aspect_w = 16,
                        aspect_h = 16,
                        length = 2.0,
                  },
            },
      },
      alpha = 191,
      paramtype = "light",
      walkable = false,
      pointable = false,
      diggable = false,
      buildable_to = true,
      is_ground_content = false,
      drop = "",
      drowning = 1,
      liquidtype = "source",
      liquid_alternative_flowing = "main:waterflow",
      liquid_alternative_source = "main:water",
      liquid_viscosity = 1,
      post_effect_color = {a = 103, r = 30, g = 60, b = 90},
      groups = {water = 1, liquid = 1, cools_lava = 1, bucket = 1, source = 1},
      --sounds = default.node_sound_water_defaults(),
})

minetest.register_node("main:waterflow", {
      description = "Water Flow",
      drawtype = "flowingliquid",
      waving = 3,
      tiles = {"water.png"},
      special_tiles = {
            {
                  name = "waterFlow.png",
                  backface_culling = false,
                  animation = {
                        type = "vertical_frames",
                        aspect_w = 16,
                        aspect_h = 16,
                        length = 0.8,
                  },
            },
            {
                  name = "waterFlow.png",
                  backface_culling = true,
                  animation = {
                        type = "vertical_frames",
                        aspect_w = 16,
                        aspect_h = 16,
                        length = 0.8,
                  },
            },
      },
      alpha = 191,
      paramtype = "light",
      paramtype2 = "flowingliquid",
      walkable = false,
      pointable = false,
      diggable = false,
      buildable_to = true,
      is_ground_content = false,
      drop = "",
      drowning = 1,
      liquidtype = "flowing",
      liquid_alternative_flowing = "main:waterflow",
      liquid_alternative_source = "main:water",
      liquid_viscosity = 1,
      post_effect_color = {a = 103, r = 30, g = 60, b = 90},
      groups = {water = 1, liquid = 1, notInCreative = 1, cools_lava = 1},
      --sounds = default.node_sound_water_defaults(),
})

--[[

minetest.register_node("default:lava_source", {
      description = S("Lava Source"),
      drawtype = "liquid",
      tiles = {
            {
                  name = "default_lava_source_animated.png",
                  backface_culling = false,
                  animation = {
                        type = "vertical_frames",
                        aspect_w = 16,
                        aspect_h = 16,
                        length = 3.0,
                  },
            },
            {
                  name = "default_lava_source_animated.png",
                  backface_culling = true,
                  animation = {
                        type = "vertical_frames",
                        aspect_w = 16,
                        aspect_h = 16,
                        length = 3.0,
                  },
            },
      },
      paramtype = "light",
      light_source = default.LIGHT_MAX - 1,
      walkable = false,
      pointable = false,
      diggable = false,
      buildable_to = true,
      is_ground_content = false,
      drop = "",
      drowning = 1,
      liquidtype = "source",
      liquid_alternative_flowing = "default:lava_flowing",
      liquid_alternative_source = "default:lava_source",
      liquid_viscosity = 7,
      liquid_renewable = false,
      damage_per_second = 4 * 2,
      post_effect_color = {a = 191, r = 255, g = 64, b = 0},
      groups = {lava = 3, liquid = 2, igniter = 1},
})

minetest.register_node("default:lava_flowing", {
      description = S("Flowing Lava"),
      drawtype = "flowingliquid",
      tiles = {"default_lava.png"},
      special_tiles = {
            {
                  name = "default_lava_flowing_animated.png",
                  backface_culling = false,
                  animation = {
                        type = "vertical_frames",
                        aspect_w = 16,
                        aspect_h = 16,
                        length = 3.3,
                  },
            },
            {
                  name = "default_lava_flowing_animated.png",
                  backface_culling = true,
                  animation = {
                        type = "vertical_frames",
                        aspect_w = 16,
                        aspect_h = 16,
                        length = 3.3,
                  },
            },
      },
      paramtype = "light",
      paramtype2 = "flowingliquid",
      light_source = default.LIGHT_MAX - 1,
      walkable = false,
      pointable = false,
      diggable = false,
      buildable_to = true,
      is_ground_content = false,
      drop = "",
      drowning = 1,
      liquidtype = "flowing",
      liquid_alternative_flowing = "default:lava_flowing",
      liquid_alternative_source = "default:lava_source",
      liquid_viscosity = 7,
      liquid_renewable = false,
      damage_per_second = 4 * 2,
      post_effect_color = {a = 191, r = 255, g = 64, b = 0},
      groups = {lava = 3, liquid = 2, igniter = 1,
            not_in_creative_inventory = 1},
})

]]--

minetest.register_node("main:ladder", {
      description = "Ladder",
      drawtype = "signlike",
      tiles = {"ladder.png"},
      inventory_image = "ladder.png",
      wield_image = "ladder.png",
      paramtype = "light",
      paramtype2 = "wallmounted",
      sunlight_propagates = true,
      walkable = false,
      climbable = true,
      is_ground_content = false,
      node_placement_prediction = "",
      selection_box = {
            type = "wallmounted",
            --wall_top = = <default>
            --wall_bottom = = <default>
            --wall_side = = <default>
      },
      groups = {wood = 2, flammable = 2, attached_node=1},
      sounds = main.woodSound(),
      on_place = function(itemstack, placer, pointed_thing)
            --copy from torch
            if pointed_thing.type ~= "node" then
                  return itemstack
            end
            
            local wdir = minetest.dir_to_wallmounted(vector.subtract(pointed_thing.under,pointed_thing.above))

            local fakestack = itemstack
            local retval = false
            if wdir > 1 then
                  retval = fakestack:set_name("main:ladder")
            else
                  return itemstack
            end
            
            if not retval then
                  return itemstack
            end
            
            itemstack, retval = minetest.item_place(fakestack, placer, pointed_thing, wdir)
            
            if retval then
                  minetest.sound_play("wood", {pos=pointed_thing.above, gain = 1.0})
            end
            
            print(itemstack, retval)
            itemstack:set_name("main:ladder")

            return itemstack
      end,
})
