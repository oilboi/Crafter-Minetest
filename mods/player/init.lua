--[[
--map
running - set fov set_fov(fov, is_multiplier) set_breath(value)
sneaking --set eye offset

]]--
minetest.register_on_joinplayer(function(player)
      --add in info
      player:hud_set_flags({minimap=true})
      player:hud_add({
            hud_elem_type = "text",
            position = {x=0,y=0},
            text = "Crafter Alpha 0.1",
            number = 000000,
            alignment = {x=1,y=1},
            offset = {x=2, y=2},
      })
      player:hud_add({
            hud_elem_type = "text",
            position = {x=0,y=0},
            text = "Crafter Alpha 0.1",
            number = 0xffffff,
            alignment = {x=1,y=1},
            offset = {x=0, y=0},
      })
end)

--hurt sound
minetest.register_on_player_hpchange(function(player, hp_change, reason)
      if hp_change < 0 then
            minetest.sound_play("hurt", {object=player, gain = 1.0, max_hear_distance = 60,pitch = math.random(80,100)/100})
      end
end)

--throw all items on death
minetest.register_on_dieplayer(function(player, reason)
      local pos = player:getpos()
      print(reason)
      local inv = player:get_inventory()
      
      for i = 1,inv:get_size("main") do
            local stack = inv:get_stack("main", i)
            local name = stack:get_name()
            local count = stack:get_count()
            print(name)
            if name ~= "" then
                  local obj = minetest.add_item(pos, name.." "..count)
                  obj:setvelocity(vector.new(math.random(-3,3),math.random(4,8),math.random(-3,3)))
                  inv:set_stack("main", i, ItemStack(""))
            end
      end
      for i = 1,inv:get_size("craft") do
      
      end 
      

end)

minetest.register_globalstep(function(dtime)
      --collection
      for _,player in ipairs(minetest.get_connected_players()) do
            local run = player:get_player_control().aux1
            local walk = player:get_player_control().up
            local sneak = player:get_player_control().sneak
            
            if run and walk and not sneak then
                  --[[ I'll impliment this in later
                  local meta = player:get_meta()
                  
                  local run_time = meta:get_float("running_timer")
                  
                  if not run_time then
                        run_time = 0
                  end
                  
                  if run_time >= 0.1 then
                        --take breath away
                        local breath = player:get_breath()
                        breath = breath - 1
                        player:set_breath(breath)
                        run_time = 0
                        print(breath)
                  end
                  
                  meta:set_float("running_timer", run_time + dtime)
                  
                  ]]--
                  
                  local fov = player:get_fov()
                  if fov == 0 then
                        fov = 1
                  end
                  
                  if fov < 1.2 then
                        player:set_fov(fov + 0.05, true)
                  end
                  
                  player:set_physics_override({speed=1.5})
            else
                  local meta = player:get_meta()
                  local fov = player:get_fov()
                  if fov > 1 then
                        player:set_fov(fov - 0.05, true)
                  end
                  
                  player:set_physics_override({speed=1})
                  --meta:set_float("running_timer", 0)
            end
            
            if sneak then
                  player:set_eye_offset({x=0,y=-1,z=0},{x=0,y=-1,z=0})
            else
                  player:set_eye_offset({x=0,y=0,z=0},{x=0,y=0,z=0})
            end
      end
end)

minetest.register_globalstep(function(dtime)
      --collection
      for _,player in ipairs(minetest.get_connected_players()) do
            if player:get_player_control().RMB then
                  local health = player:get_wielded_item():get_definition().health
                  if health then
                        local meta = player:get_meta()
                        local eating = meta:get_float("eating")
                        
                        if meta:get_int("eating_ps") == 0 then
                              local ps = minetest.add_particlespawner({
                                    amount = 100,
                                    time = 0,
                                    minpos = {x=0, y=-1.5, z=0.5},
                                    maxpos = {x=0, y=1.7, z=0.5},
                                    minvel = vector.new(-0.5,0,-0.5),
                                    maxvel = vector.new(0.5,0,0.5),
                                    minacc = {x=0, y=-9.81, z=1},
                                    maxacc = {x=0, y=-9.81, z=1},
                                    minexptime = 0.5,
                                    maxexptime = 1.5,
                                    minsize = 1,
                                    maxsize = 2,
                                    attached = player,
                                    collisiondetection = true,
                                    vertical = false,
                                    texture = "treecapitator.png"
                              })
                              meta:set_int("eating_ps", ps)
                        end
                              
                        if eating + dtime >= 2 then
                              local stack = player:get_wielded_item()
                              stack:take_item(1)
                              player:set_wielded_item(stack)
                              player:set_hp(player:get_hp() + health)
                              eating = 0
                              minetest.sound_play("eat", {
                                    object = player,
                                    gain = 1.0,  -- default
                                    max_hear_distance = 32,  -- default, uses an euclidean metric
                                    pitch = math.random(70,100)/100,
                              })
                        end
                        meta:set_float("eating", eating + dtime)
                  else
                        local meta = player:get_meta()
                        meta:set_float("eating", 0)
                        minetest.delete_particlespawner(meta:get_int("eating_ps"))
                        meta:set_int("eating_ps", 0)
                        
                  end
            else
                  local meta = player:get_meta()
                  meta:set_float("eating", 0)
                  minetest.delete_particlespawner(meta:get_int("eating_ps"))
                  meta:set_int("eating_ps", 0)
            end
            
      end
end)

