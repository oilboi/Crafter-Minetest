minetest.register_node("redstone:wire",{
      description = "Redstone Wire",
      wield_image = "redstone_dust.png",
      paramtype = "light",
      drawtype = "nodebox",
      --paramtype2 = "wallmounted",
      walkable = false,
      node_box = {
            type = "connected",
            --{xmin, ymin, zmin, xmax, ymax, zmax}

            fixed = {-1/16, -1/2, -1/16, 1/16, -7/16, 1/16},
            
            disconnected_sides  = {-1/16, -1/2, -1/16, 1/16, 1/2, 1/16},

            connect_top = {-1/16, -1/2, -1/16, 1/16, 1/2, 1/16},
            -- connect_bottom =
            connect_front = {-1/16, -1/2, -1/2, 1/16, -7/16, 1/16},
            connect_left =  {-1/2, -1/2, -1/16, 1/16, -7/16, 1/16},
            connect_back =  {-1/16, -1/2, -1/16, 1/16, -7/16, 1/2},
            connect_right = {-1/16, -1/2, -1/16, 1/2, -7/16, 1/16},
      },
      collision_box = {
            type = "connected",
            --{xmin, ymin, zmin, xmax, ymax, zmax}

            fixed = {-1/16, -1/2, -1/16, 1/16, -7/16, 1/16},
            -- connect_top =
            -- connect_bottom =
            connect_front = {-1/16, -1/2, -1/2, 1/16, -7/16, 1/16},
            connect_left =  {-1/2, -1/2, -1/16, 1/16, -7/16, 1/16},
            connect_back =  {-1/16, -1/2, -1/16, 1/16, -7/16, 1/2},
            connect_right = {-1/16, -1/2, -1/16, 1/2, -7/16, 1/16},
      },
      connects_to = {"group:redstone"},
      inventory_image = fence_texture,
      wield_image = fence_texture,
      tiles = {"redstone_dust.png"},
      sunlight_propagates = true,
      is_ground_content = false,
      groups = {redstone =1, instant=1},
})
