--grass spread abm
minetest.register_abm({
      label = "Grass Grow",
      nodenames = {"main:dirt"},
      neighbors = {"main:grass"},
      interval = 10,
      chance = 2000,
      action = function(pos)
            local light = minetest.get_node_light(pos, nil)
            --print(light)
            if light < 10 then
                  --print("failed to grow grass at "..dump(pos))
                  return
            end
            minetest.set_node(pos,{name="main:grass"})
      end,
})
