minetest.register_tool("jetpack:jetpack",{
    description = "Jetpack",

    groups = {chestplate = 1,},
    inventory_image = "jetpack_item.png",
    stack_max = 1,
    wearing_texture = "jetpack.png",
    tool_capabilities = {
        full_punch_interval = 0,
        max_drop_level = 0,
        groupcaps = {
        },
        damage_groups = {

        },
        punch_attack_uses = 0,
    }
})

local sound_handling_loop = {}

minetest.register_globalstep(function(dtime)
    for _,player in ipairs(minetest.get_connected_players()) do
        local player_name = player:get_player_name()
        if player:get_hp() > 0 then
            if player:get_player_control().jump or player:get_player_control().sneak then
                local inv = player:get_inventory()
                local stack = inv:get_stack("armor_torso",1)
                local name = stack:get_name()
                if name ~= "" and name == "jetpack:jetpack" then
                    --boost
                    if player:get_player_control().jump and player:get_player_velocity().y < 20 then
                        player:add_player_velocity(vector.new(0,1,0))
                    --hover
                    elseif player:get_player_control().sneak then
                        local currentvel = player:get_player_velocity()
                        local goal = 8.1
			            local acceleration = vector.new(0,goal-currentvel.y,0)
			            acceleration = vector.multiply(acceleration, 0.05)
			            player:add_player_velocity(acceleration)
                    end
                    
                    local particle_pos = player:get_pos()
                    local yaw = player:get_look_horizontal()
                    local p_dir = vector.divide(minetest.yaw_to_dir(yaw + math.pi),8)
                    particle_pos.y = particle_pos.y + 0.7
                    particle_pos = vector.add(particle_pos,p_dir)


                    minetest.add_particle({
						pos = particle_pos,
						velocity = {x=0, y=-20+player:get_player_velocity().y , z=0},
						acceleration = {x=math.random(-1,1), y=0, z=math.random(-1,1)},
						expirationtime = 1+math.random(),
						size = 1+math.random(),
						texture = "smoke.png",
					})
                    stack:add_wear(5)
                    inv:set_stack("armor_torso", 1, stack)

                    if not sound_handling_loop[player_name] then
                        sound_handling_loop[player_name] = minetest.sound_play("jetpack", {object = player,loop=true})
                    end

                    if inv:get_stack("armor_torso",1):get_name() == "" then
                        recalculate_armor(player)
                        set_armor_gui(player)
                        if sound_handling_loop[player_name] then
                            --minetest.sound_play("armor_break",{to_player=player:get_player_name(),gain=1,pitch=math.random(80,100)/100})
                            --minetest.sound_stop(sound_handling_loop[player_name])
                            minetest.sound_fade(sound_handling_loop[player_name], -1, 0)
                            sound_handling_loop[player_name] = nil
                        end
                    end
                end
            elseif sound_handling_loop[player_name] then
                minetest.sound_stop(sound_handling_loop[player_name])
                sound_handling_loop[player_name] = nil
            end
        end
    end
end)

minetest.register_craft({
    output = "jetpack:jetpack",
    recipe = {
        {"main:iron"           , "main:gold"    , "main:iron"          },
        {"main:iron"           , "main:diamond" , "main:iron"          },
        {"redstone:piston_off" , "redstone:dust", "redstone:piston_off"}
    }
})