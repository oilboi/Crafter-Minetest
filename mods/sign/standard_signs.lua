-- Definitions for standard minetest_game wooden and steel wall signs

signs_lib.register_sign("sign:sign", {
      description = "Sign",
      inventory_image = "signs_lib_sign_wall_wooden_inv.png",
      tiles = {
            "signs_lib_sign_wall_wooden.png",
            "signs_lib_sign_wall_wooden_edges.png",
            -- items 3 - 5 are not set, so signs_lib will use its standard pole
            -- mount, hanging, and yard sign stick textures.
      },
      entity_info = "standard",
      allow_hanging = true,
      allow_widefont = true,
      allow_onpole = true,
      allow_onpole_horizontal = true,
      allow_yard = true
})

minetest.register_craft({
      output = "sign:sign 3",
      recipe = {
            {"main:wood","main:wood","main:wood"},
            {"main:wood","main:wood","main:wood"},
            {"","main:stick",""}
      }
})

--[[
table.insert(signs_lib.lbm_restore_nodes, "signs:sign_hanging")
table.insert(signs_lib.lbm_restore_nodes, "basic_signs:hanging_sign")
table.insert(signs_lib.lbm_restore_nodes, "signs:sign_yard")
table.insert(signs_lib.lbm_restore_nodes, "basic_signs:yard_sign")
table.insert(signs_lib.lbm_restore_nodes, "default:sign_wood_yard")
table.insert(signs_lib.lbm_restore_nodes, "default:sign_wall_wood_yard")

-- insert the old wood sign-on-fencepost into signs_lib's conversion LBM

table.insert(signs_lib.old_fenceposts_with_signs, "signs:sign_post")
signs_lib.old_fenceposts["signs:sign_post"] = "default:fence_wood"
signs_lib.old_fenceposts_replacement_signs["signs:sign_post"] = "default:sign_wall_wood_onpole"
]]--
