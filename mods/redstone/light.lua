local minetest = minetest

local colors = {
  "white",
  "yellow",
  "green",
  "blue",
  "violet",
  "red",
  "orange",
  "black"
}

--this allows for a more pale off state so players have more freedom to create different colors
for _,color in pairs(colors) do
  minetest.register_node("redstone:light_on_"..color, {
      description = color:gsub("^%l", string.upper).." Redstone Light",
      tiles = {"redstone_light.png^[colorize:"..color..":200"},
      drawtype = "normal",
      light_source = 12,
      groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,pathable = 1},
      sounds = main.stoneSound({
      footstep = {name = "glass_footstep", gain = 0.4},
          dug =  {name = "break_glass", gain = 0.4},
    }),
      drop = "redstone:light_off_"..color,

      after_place_node = function(pos, placer, itemstack, pointed_thing)
        redstone.inject(pos,{
          name = "redstone:light_on_"..color,
          activator = true,
        })

        redstone.update(pos)
      end,
      after_destruct = function(pos, oldnode)
        redstone.inject(pos,nil)
        redstone.update(pos)
      end
  })

  redstone.register_activator({
    name = "redstone:light_on_"..color,
    deactivate = function(pos)

      minetest.swap_node(pos,{name="redstone:light_off_"..color})

      redstone.inject(pos,{
        name = "redstone:light_off_"..color,
        activator = true,
      })
    end
  })

  minetest.register_lbm({
    name = "redstone:light_on_"..color,
    nodenames = {"redstone:light_on_"..color},
    run_at_every_load = true,
    action = function(pos)
      redstone.inject(pos,{
        name = "redstone:light_on_"..color,
        activator = true,
      })

      minetest.after(0,function()
        redstone.update(pos)
      end)
    end,
  })



  minetest.register_node("redstone:light_off_"..color, {
      description = color:gsub("^%l", string.upper).." Redstone Light",
      tiles = {"redstone_light.png^[colorize:"..color..":100"},
      drawtype = "normal",
      groups = {stone = 1, hard = 1, pickaxe = 1, hand = 4,pathable = 1,redstone_activation=1},
      sounds = main.stoneSound({
      footstep = {name = "glass_footstep", gain = 0.4},
          dug =  {name = "break_glass", gain = 0.4},
    }),
      drop = "redstone:light_off_"..color,
      

      after_place_node = function(pos, placer, itemstack, pointed_thing)
        redstone.inject(pos,{
          name = "redstone:light_off_"..color,
          activator = true,
        })

        redstone.update(pos)
      end,
      
      after_destruct = function(pos, oldnode)
        redstone.inject(pos,nil)
        redstone.update(pos)
      end
  })


  redstone.register_activator({
    name = "redstone:light_off_"..color,
    activate = function(pos)

      minetest.swap_node(pos,{name="redstone:light_on_"..color})

      redstone.inject(pos,{
        name = "redstone:light_on_"..color,
        activator = true,
      })
    end
  })

  minetest.register_lbm({
    name = "redstone:light_off_"..color,
    nodenames = {"redstone:light_off_"..color},
    run_at_every_load = true,
    action = function(pos)
      redstone.inject(pos,{
        name = "redstone:light_off_"..color,
        activator = true,
      })

      minetest.after(0,function()
        redstone.update(pos)
      end)
    end,
  })



  minetest.register_craft({
    output = "redstone:light_off_"..color,
    type = "shapeless",
    recipe = {"main:glass","redstone:dust","dye:"..color},
  })
end