minetest.override_item("main:ironblock",{
    on_construct = function(pos)
        redstone.inject(pos,{
          name = "main:ironblock",
          activator = true,
          capacitor = 0,
        })
        minetest.after(0,function()
            redstone.update(pos)
            redstone.update(pos,true)
        end)
    end,
    after_destruct = function(pos, oldnode)
        redstone.inject(pos,nil)
        redstone.update(pos)
        redstone.update(pos,true)
    end
})

redstone.register_activator({
    name = "main:ironblock",
    activate = function(pos)
        minetest.swap_node(pos,{name="main:ironblock_on"})
        redstone.inject(pos,{
            name = "main:ironblock_on",
            capacitor = 1,
            source    = true,
            activator = true,
        })
        redstone.update(pos)
        redstone.update(pos,true)
    end,
  })

redstone.register_capacitor({
    name = "main:ironblock",
    on   = "main:ironblock_on",
    off  = "main:ironblock",
})

minetest.register_lbm({
    name = ":main:ironblock",
    nodenames = {"main:ironblock"},
    run_at_every_load = true,
    action = function(pos)
        redstone.inject(pos,{
            name = "main:ironblock",
            activator = true,
            capacitor = 0,
          })
          minetest.after(0,function()
              redstone.update(pos)
              --redstone.update(pos,true)
          end)
    end,
})


minetest.register_node(":main:ironblock_on", {
    description = "Iron Block Activated",
    tiles = {"ironblock.png^[colorize:white:100"},
    groups = {stone = 2, pathable = 1},
    sounds = main.stoneSound(),
    light_source = 10,
    drop = {
        max_items = 1,
        items= {
            {
                rarity = 0,
                tools = {"main:coalpick","main:stonepick","main:ironpick","main:lapispick","main:goldpick","main:diamondpick","main:emeraldpick","main:sapphirepick","main:rubypick"},
                items = {"main:ironblock"},
            },
            },
        },
    on_construct = function(pos)
        redstone.inject(pos,{
            name = "main:ironblock_on",
            activator = true,
            source = true,
            capacitor = 1,
        })
        minetest.after(0,function()
            redstone.update(pos)
            redstone.update(pos,true)
        end)
    end,
    after_destruct = function(pos, oldnode)
        redstone.inject(pos,nil)
        redstone.update(pos)
        redstone.update(pos,true)
    end,
})


redstone.register_activator({
    name = "main:ironblock_on",
    deactivate = function(pos)

        minetest.swap_node(pos,{name="main:ironblock"})
        redstone.inject(pos,{
            name = "main:ironblock",
            capacitor = 0,
            activator = true,
        })
        redstone.update(pos)
        redstone.update(pos,true)
    end,
})

redstone.register_capacitor({
    name = "main:ironblock_on",
    on   = "main:ironblock_on",
    off  = "main:ironblock",
})


minetest.register_lbm({
    name = ":main:ironblock_on",
    nodenames = {"main:ironblock_on"},
    run_at_every_load = true,
    action = function(pos)
        redstone.inject(pos,{
            name = "main:ironblock",
            activator = true,
            source = true,
            capacitor = 1,
        })
        minetest.after(0,function()
            redstone.update(pos)
            --redstone.update(pos,true)
        end)
    end,
})