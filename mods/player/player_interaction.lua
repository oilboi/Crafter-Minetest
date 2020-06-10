--hurt sound and disable fall damage group handling
minetest.register_on_player_hpchange(function(player, hp_change, reason)
	if reason.type == "fall" then
		if minetest.get_item_group(minetest.get_node(player:get_pos()).name, "disable_fall_damage") > 0 then
			return(0)
		else
			--boots absorb fall damage
			local fall_damage = math.floor(player:get_player_velocity().y+0.5)+13
			--print("fall damage:",fall_damage)
			local inv = player:get_inventory()
			local stack = inv:get_stack("armor_feet", 1)
			local name = stack:get_name()
			if name ~= "" then
				local absorption = 0

				absorption = minetest.get_item_group(name,"armor_level")*2
				--print("absorbtion:",absorption)
				local wear_level = ((9-minetest.get_item_group(name,"armor_level"))*8)*(5-minetest.get_item_group(name,"armor_type"))*math.abs(fall_damage)
				
				stack:add_wear(wear_level)
				
				inv:set_stack("armor_feet", 1, stack)
				
				local new_stack = inv:get_stack("armor_feet",1):get_name()

        		if new_stack == "" then					
					minetest.sound_play("armor_break",{to_player=player:get_player_name(),gain=1,pitch=math.random(80,100)/100})
					armor_class.recalculate_armor(player)
					armor_class.set_armor_gui(player)
					--do particles too
				elseif minetest.get_item_group(new_stack,"boots") > 0 then 
					local pos = player:get_pos()
					minetest.add_particlespawner({
						amount = 30,
						time = 0.00001,
						minpos = {x=pos.x-0.5, y=pos.y+0.1, z=pos.z-0.5},
						maxpos = {x=pos.x+0.5, y=pos.y+0.1, z=pos.z+0.5},
						minvel = vector.new(-0.5,1,-0.5),
						maxvel = vector.new(0.5 ,2 ,0.5),
						minacc = {x=0, y=-9.81, z=1},
						maxacc = {x=0, y=-9.81, z=1},
						minexptime = 0.5,
						maxexptime = 1.5,
						minsize = 0,
						maxsize = 0,
						--attached = player,
						collisiondetection = true,
						collision_removal = true,
						vertical = false,
						node = {name= name.."particletexture"},
						--texture = "eat_particles_1.png"
					})
					minetest.sound_play("armor_fall_damage", {object=player, gain = 1.0, max_hear_distance = 60,pitch = math.random(80,100)/100})	
				end

				fall_damage = fall_damage + absorption

				if fall_damage >= 0 then
					fall_damage = 0
				else
					minetest.sound_play("hurt", {object=player, gain = 1.0, max_hear_distance = 60,pitch = math.random(80,100)/100})
				end
			else
				minetest.sound_play("hurt", {object=player, gain = 1.0, max_hear_distance = 60,pitch = math.random(80,100)/100})
			end
			--print("returned fall damage",fall_damage)
			return(fall_damage)
		end
	elseif hp_change < 0 then
		minetest.sound_play("hurt", {object=player, gain = 1.0, max_hear_distance = 60,pitch = math.random(80,100)/100})
	end
	return(hp_change)
end, true)

--throw all items on death
minetest.register_on_dieplayer(function(player, reason)
	local pos = player:get_pos()
	local inv = player:get_inventory()
	
	for i = 1,inv:get_size("main") do
		local stack = inv:get_stack("main", i)
		local name = stack:get_name()
		local count = stack:get_count()
		if name ~= "" then
			local obj = minetest.add_item(pos, stack)
			if obj then
				obj:set_velocity(vector.new(math.random(-3,3),math.random(4,8),math.random(-3,3)))
			end
			inv:set_stack("main", i, ItemStack(""))
		else
			inv:set_stack("main", i, ItemStack(""))
		end
	end

	local stack = inv:get_stack("armor_head", 1)
	local name = stack:get_name()
	if name ~= "" then
		local obj = minetest.add_item(pos, stack)
		if obj then
			obj:set_velocity(vector.new(math.random(-3,3),math.random(4,8),math.random(-3,3)))
		end
		inv:set_stack("armor_head", 1, ItemStack(""))
	end

	stack = inv:get_stack("armor_torso", 1)
	name = stack:get_name()
	if name ~= "" then
		local obj = minetest.add_item(pos, stack)
		if obj then
			obj:set_velocity(vector.new(math.random(-3,3),math.random(4,8),math.random(-3,3)))
		end
		inv:set_stack("armor_torso", 1, ItemStack(""))
	end

	stack = inv:get_stack("armor_legs", 1)
	name = stack:get_name()
	if name ~= "" then
		local obj = minetest.add_item(pos, stack)
		if obj then
			obj:set_velocity(vector.new(math.random(-3,3),math.random(4,8),math.random(-3,3)))
		end
		inv:set_stack("armor_legs", 1, ItemStack(""))
	end


	stack = inv:get_stack("armor_feet", 1)
	name = stack:get_name()
	if name ~= "" then
		local obj = minetest.add_item(pos, stack)
		if obj then
			obj:set_velocity(vector.new(math.random(-3,3),math.random(4,8),math.random(-3,3)))
		end
		inv:set_stack("armor_feet", 1, ItemStack(""))
	end


	armor_class.recalculate_armor(player)
end)


--this dumps the players crafting table on closing the inventory
dump_craft = function(player)
	local inv = player:get_inventory()
	local pos = player:get_pos()
	pos.y = pos.y + player:get_properties().eye_height
	for i = 1,inv:get_size("craft") do
		local item = inv:get_stack("craft", i)
		local obj = minetest.add_item(pos, item)
		if obj then
			local x=math.random(-2,2)*math.random()
			local y=math.random(2,5)
			local z=math.random(-2,2)*math.random()
			obj:set_velocity({x=x, y=y, z=z})
		end
		inv:set_stack("craft", i, nil)
	end
end


--play sound to keep up with player's placing vs inconsistent client placing sound 
minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	local node = minetest.registered_nodes[newnode.name]
	local sound = node.sounds
	local placing = ""
	if sound then
		placing = sound.placing
	end
	--only play the sound when is defined
	if type(placing) == "table" then
		minetest.sound_play(placing.name, {
			  pos = pos,
			  gain = placing.gain,
			  --pitch = math.random(60,100)/100
		})
	end
end)

--replace stack when empty (building)
minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	local old = itemstack:get_name()
	--pass through to check
	minetest.after(0,function(pos, newnode, placer, oldnode, itemstack, pointed_thing,old)
		if not placer then
			return
		end
		local new = placer:get_wielded_item():get_name()
		if old ~= new and new == "" then
			local inv = placer:get_inventory()
			--check if another stack
			if inv:contains_item("main", old) then
				--print("moving stack")
				--run through inventory
				for i = 1,inv:get_size("main") do
					--if found set wielded item and remove old stack
					if inv:get_stack("main", i):get_name() == old then
						local count = inv:get_stack("main", i):get_count()
						placer:set_wielded_item(old.." "..count)
						inv:set_stack("main",i,ItemStack(""))	
						minetest.sound_play("pickup", {
							  to_player = player,
							  gain = 0.7,
							  pitch = math.random(60,100)/100
						})
						return				
					end
				end
			end
		end
	end,pos, newnode, placer, oldnode, itemstack, pointed_thing,old)
end)

local do_critical_particles = function(pos)
	minetest.add_particlespawner({
		amount = 40,
		time = 0.001,
		minpos = pos,
		maxpos = pos,
		minvel = vector.new(-2,-2,-2),
		maxvel = vector.new(2,8,2),
		minacc = {x=0, y=4, z=0},
		maxacc = {x=0, y=12, z=0},
		minexptime = 1.1,
		maxexptime = 1.5,
		minsize = 1,
		maxsize = 2,
		collisiondetection = false,
		vertical = false,
		texture = "critical.png",
	})
end

--we need to do this to override the default damage mechanics
minetest.register_on_joinplayer(function(player)
	local meta = player:get_meta()
	meta:set_float("player_punch_timer",0)
end)

minetest.register_globalstep(function(dtime)
	for _,player in ipairs(minetest.get_connected_players()) do
		local meta = player:get_meta()
		local punch_timer = meta:get_float("player_punch_timer")

		--limit this so the game engine isn't calculating huge floats
		if punch_timer > 0 then
			punch_timer = punch_timer - dtime
			if punch_timer < 0 then punch_timer = 0 end
			meta:set_float("player_punch_timer",punch_timer)
		end
	end
end)

--this throws the player when they're punched and activates the custom damage mechanics
minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	local meta = player:get_meta()
	local punch_timer = meta:get_float("player_punch_timer")
	local hurt = tool_capabilities.damage_groups.damage
	local hp = player:get_hp()
	if punch_timer <= 0 and hp > 0 then
		meta:set_float("player_punch_timer",0.25)
		if hitter:is_player() and hitter ~= player then
			local puncher_vel = hitter:get_player_velocity().y
			if puncher_vel < 0 then
				hurt = hurt * 1.5
				critical = true
				do_critical_particles(player:get_pos())
				minetest.sound_play("critical", {pos=player:get_pos(), gain = 0.1, max_hear_distance = 16,pitch = math.random(80,100)/100})
			end
		end

		dir = vector.multiply(dir,10)
		local vel = player:get_player_velocity()
		dir.y = 0
		if vel.y <= 0 then
			dir.y = 7
		end

		local hp_modifier = math.ceil(armor_class.calculate_armor_absorbtion(player)/3)
		--print("hp_modifier:",hp_modifier)
		armor_class.damage_armor(player,math.abs(hurt))

		--print("hurt:",hurt,"|","hp_modifier:",hp_modifier)
		local modify_output = (hurt == 0)
		
		hurt = hurt - hp_modifier

		if modify_output == false and hurt <= 0 then
			hurt = 1
		elseif modify_output == true then
			hurt = 0
		end
		player:add_player_velocity(dir)
		player:set_hp(hp-hurt)
	end
end)


