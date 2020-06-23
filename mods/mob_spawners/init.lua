dungeon_loot = {}

dungeon_loot.CHESTS_MIN = 10 -- not necessarily in a single dungeon
dungeon_loot.CHESTS_MAX = 50
dungeon_loot.STACKS_PER_CHEST_MAX = 10

mob_spawners = {}

function register_mob_spawner(mobname,texture,mesh)
    minetest.register_node(":mob_spawners:"..mobname,{
        description = mobname:gsub("^%l", string.upper).." Spawner",
        drawtype = "allfaces",
		tiles = {"spawner.png"},
		groups = {stone = 3, pathable = 1},
        sounds = main.stoneSound(),
        sunlight_propagates = true,
        paramtype = "light",
        drop = "",
        on_construct = function(pos)
            minetest.add_entity(pos, "mob_spawners:"..mobname)
        end,
        after_destruct = function(pos)
            for _,object in ipairs(minetest.get_objects_inside_radius(pos, 0.5)) do
                if not object:is_player() then
                    if object:get_luaentity().name == "mob_spawners:"..mobname then
                        object:remove()
                        return
                    end
                end
            end
        end
    })

    table.insert(mob_spawners,"mob_spawners:"..mobname)
    print(dump(mob_spawners))

    minetest.register_lbm({
        name = ":mob_spawners:"..mobname,
        nodenames = {"mob_spawners:"..mobname},
        action = function(pos)
            minetest.add_entity(pos, "mob_spawners:"..mobname)
        end,
    })

    minetest.register_abm({
        label = "mob_spawners:"..mobname,
        nodenames = {"mob_spawners:"..mobname},
        neighbors = {"air"},
        interval = 5,
        chance = 1,
        action = function(pos)
            --readd the mob visual
            local found = false
            for _,object in ipairs(minetest.get_objects_inside_radius(pos, 0.5)) do
                if not object:is_player() then
                    if object:get_luaentity().name == "mob_spawners:"..mobname then
                        found = true
                        break
                    end
                end
            end
            if found == false then
                minetest.add_entity(pos, "mob_spawners:"..mobname)
            end

            local mobcount = 0
            for _,object in ipairs(minetest.get_objects_inside_radius(pos, 5)) do
                if not object:is_player() and object:get_luaentity().mobname then
                    mobcount = mobcount + 1
                    if mobcount > 5 then
                        return
                    end
                end
            end

            for i = 1,math.random(2,4) do
                local newpos = minetest.find_node_near(pos, 5, {"air"})
                if newpos then
                    minetest.add_entity(newpos,"mob:"..mobname)
                end
            end
	    end,
    })

    local spawner_entity = {}
    spawner_entity.initial_properties = {
        physical = false,
        collide_with_objects = false,
        collisionbox = {0,0,0,0,0,0},
        visual = "mesh",
        visual_size = {x=1,y=1,z=1},
        mesh = mesh,
        textures = texture,
        is_visible = true,
        pointable = false,
        makes_footstep_sound = false,
        static_save = false,
        automatic_rotate = 3
    }

    minetest.register_entity(":mob_spawners:"..mobname, spawner_entity)
end

dofile(minetest.get_modpath("mob_spawners") .. "/loot.lua")
dofile(minetest.get_modpath("mob_spawners") .. "/mapgen.lua")