--
mobs.create_interaction_functions = function(def,mob_register)
	--the sword wear mechanic
	mob_register.add_sword_wear = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		if puncher:is_player() then
			local itemstack = puncher:get_wielded_item()
			local wear = itemstack:get_definition().mob_hit_wear
			if wear then
				itemstack:add_wear(wear)
				if itemstack:get_name() == "" then
					minetest.sound_play("tool_break",{to_player = puncher:get_player_name(),gain=0.4})
				end
				puncher:set_wielded_item(itemstack)
			end
		end
	end

	--critical effect particles
	mob_register.do_critical_particles = function(pos)
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
	
	mob_register.collision_detection = function(self)
		local pos = self.object:get_pos()
		--do collision detection from the base of the mob
		
		local collisionbox = self.object:get_properties().collisionbox

		pos.y = pos.y + collisionbox[2]
		
		local collision_boundary = collisionbox[4]

		local radius = collision_boundary

		if collisionbox[5] > collision_boundary then
			radius = collisionbox[5]
		end

		for _,object in ipairs(minetest.get_objects_inside_radius(pos, radius*1.25)) do
			if object ~= self.object and (object:is_player() or object:get_luaentity().mob == true) and
			--don't collide with rider, rider don't collide with thing
			(not object:get_attach() or (object:get_attach() and object:get_attach() ~= self.object)) and 
			(not self.object:get_attach() or (self.object:get_attach() and self.object:get_attach() ~= object)) then

				local pos2 = object:get_pos()
				
				local object_collisionbox = object:get_properties().collisionbox

				pos2.y = pos2.y + object_collisionbox[2]

				local object_collision_boundary = object_collisionbox[4]


				--this is checking the difference of the object collided with's possision
				--if positive top of other object is inside (y axis) of current object
				local y_base_diff = (pos2.y + object_collisionbox[5]) - pos.y

				local y_top_diff = (pos.y + collisionbox[5]) - pos2.y


				

				local distance = vector.distance(vector.new(pos.x,0,pos.z),vector.new(pos2.x,0,pos2.z))

				if distance <= collision_boundary + object_collision_boundary and y_base_diff >= 0 and y_top_diff >= 0 then

					local dir = vector.direction(pos,pos2)
					dir.y = 0
					
					--eliminate mob being stuck in corners
					if dir.x == 0 and dir.z == 0 then
						dir = vector.new(math.random(-1,1)*math.random(),0,math.random(-1,1)*math.random())
					end
					
					local velocity = vector.multiply(dir,1.1)
					
					local vel1 = vector.multiply(velocity, -1)
					local vel2 = velocity
					self.object:add_velocity(vel1)
					
					if object:is_player() then
						object:add_player_velocity(vel2)
					else
						object:add_velocity(vel2)
					end
				end
			end
		end
	end
	if def.takes_fall_damage == nil or def.takes_fall_damage == true then
		mob_register.fall_damage = function(self)
			local vel = self.object:get_velocity()
			if vel and self.oldvel then
				if self.oldvel.y < -7 and vel.y == 0 then
					local damage = math.abs(self.oldvel.y + 7)
					damage = math.floor(damage/1.5)
					self.object:punch(self.object, 2, 
						{
						full_punch_interval=1.5,
						damage_groups = {damage=damage},
						})
				end
			end
			self.oldvel = vel
		end
	end

	--this controls what happens when the mob gets punched
	mob_register.on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		local hp = self.hp
		local vel = self.object:get_velocity()
		local hurt = tool_capabilities.damage_groups.damage
		
		if not hurt then
			hurt = 1
		end
		
		local critical = false
		
		--criticals
		local pos = self.object:get_pos()
		if puncher:is_player() then
			local puncher_vel = puncher:get_player_velocity().y
			if puncher_vel < 0 then
				hurt = hurt * 1.5
				critical = true
			end
		end
		
		local hp = hp-hurt

		if (self.punched_timer <= 0 and hp > 1) and not self.dead then
			self.object:set_texture_mod("^[colorize:"..self.damage_color..":130")
			self.hurt_color_timer = 0.25
			if puncher ~= self.object then
				self.punched_timer = 0.8
				if self.attacked_hostile then
					self.hostile = true
					self.hostile_timer = 20
					if self.group_attack == true then
						for _,object in ipairs(minetest.get_objects_inside_radius(pos, self.view_distance)) do
							if not object:is_player() and object:get_luaentity() and object:get_luaentity().mobname == self.mobname then
								object:get_luaentity().hostile = true
								object:get_luaentity().hostile_timer = 20
							end
						end
					end
				end
			end
			
			--critical effect
			if critical == true then
				self.do_critical_particles(pos)
				minetest.sound_play("critical", {object=self.object, gain = 0.1, max_hear_distance = 10,pitch = math.random(80,100)/100})
			end
			minetest.sound_play(self.hurt_sound, {object=self.object, gain = 1.0, max_hear_distance = 10,pitch = math.random(100,140)/100})
			
			self.hp = hp
			
			self.direction = vector.multiply(dir,-1)
			dir = vector.multiply(dir,10)
			if vel.y <= 0 then
				dir.y = 4
			else
				dir.y = 0
			end
			
			
			self.object:add_velocity(dir)
			self.add_sword_wear(self, puncher, time_from_last_punch, tool_capabilities, dir)
		elseif (self.punched_timer <= 0 and self.death_animation_timer == 0) then
			self.object:set_texture_mod("^[colorize:"..self.damage_color..":130")
			self.hurt_color_timer = 0.25
			if puncher ~= self.object then
				self.punched_timer = 0.8
				if self.attacked_hostile then
					self.hostile = true
					self.hostile_timer = 20
					if self.group_attack == true then
						for _,object in ipairs(minetest.get_objects_inside_radius(pos, self.view_distance)) do
							if not object:is_player() and object:get_luaentity() and object:get_luaentity().mobname == self.mobname then
								object:get_luaentity().hostile = true
								object:get_luaentity().hostile_timer = 20
							end
						end
					end
				end
			end
			self.death_animation_timer = 1
			self.dead = true
			
			--critical effect
			if critical == true then
				self.do_critical_particles(pos)
				minetest.sound_play("critical", {object=self.object, gain = 0.1, max_hear_distance = 10,pitch = math.random(80,100)/100})
			end
			minetest.sound_play(self.die_sound, {object=self.object, gain = 1.0, max_hear_distance = 10,pitch = math.random(80,100)/100})
			self.add_sword_wear(self, puncher, time_from_last_punch, tool_capabilities, dir)
		end
	end

	--this is what happens when a mob dies
	mob_register.on_death = function(self, killer)
		local pos = self.object:get_pos()
		--pos.y = pos.y + 0.4
		minetest.sound_play("mob_die", {pos = pos, gain = 1.0})
		minetest.add_particlespawner({
			amount = 40,
			time = 0.001,
			minpos = pos,
			maxpos = pos,
			minvel = vector.new(-5,-5,-5),
			maxvel = vector.new(5,5,5),
			minacc = {x=0, y=0, z=0},
			maxacc = {x=0, y=0, z=0},
			minexptime = 1.1,
			maxexptime = 1.5,
			minsize = 1,
			maxsize = 2,
			collisiondetection = false,
			vertical = false,
			texture = "smoke.png",
		})
		
		--only throw items if registered
		if self.item_drop then
			--detect if multiple items are going to be added
			if self.item_max then
				local data_item_amount = math.random(self.item_minimum, self.item_max)
				for i = 1 ,data_item_amount do
					minetest.throw_item(vector.new(pos.x,pos.y+0.1,pos.z),self.item_drop)
				end
			else
				minetest.throw_item(vector.new(pos.x,pos.y+0.1,pos.z),self.item_drop)
			end
		end
			
		global_mob_amount = global_mob_amount - 1
		print("Mobs Died. Current Mobs: "..global_mob_amount)
		
		if self.custom_on_death then
			self.custom_on_death(self)
		end

		self.object:remove()
	end
	
	--the pig will look for and at players
	mob_register.look_around = function(self,dtime)
		local pos = self.object:get_pos()
		
		if self.die_in_light and self.die_in_light_level and self.die_in_light == true then
			local light_level = minetest.get_node_light(pos)
			if light_level then
				if (self.die_in_light == true and light_level > self.die_in_light_level) then
					local damage = self.hp
					self.object:punch(self.object, 2, 
						{
						full_punch_interval=1.5,
						damage_groups = {damage=damage},
					})
				end
			end
		end
		
		--STARE O_O
		--and follow!
		self.following = false
		local player_found = false

		for _,object in ipairs(minetest.get_objects_inside_radius(pos, self.view_distance)) do
			if object:is_player() and player_found == false and object:get_hp() > 0 then
				--look at player's camera
				local pos2 = object:get_pos()
				pos2.y = pos2.y + 1.625
				
				player_found = true
				
				if self.head_bone then
 					self.move_head(self,pos2,dtime)
				end
				
				--print(self.hostile)
				if self.hostile == true then
					local distance = vector.distance(pos,pos2)
					self.following_pos = vector.new(pos2.x,pos2.y-1.625,pos2.z)

					--punch the player
					if self.attack_type == "punch" then
						if distance < 2.5 and self.punch_timer <= 0 and object:get_hp() > 0 then
							local line_of_sight = minetest.line_of_sight(pos, pos2)
							if line_of_sight == true then
								self.punch_timer = 1
								object:punch(self.object, 2, 
									{
									full_punch_interval=1.5,
									damage_groups = {fleshy=2},
								},vector.direction(pos,pos2))
							end
						end
					elseif self.attack_type == "explode" then
						--mob will not explode if it cannot see you
						if distance <  self.explosion_radius and minetest.line_of_sight(vector.new(pos.x,pos.y+self.object:get_properties().collisionbox[5],pos.z), pos2) then
							
							if not self.tnt_timer then
								minetest.sound_play("tnt_ignite", {object = self.object, gain = 1.0,})
								self.tnt_timer = self.explosion_time
								self.tnt_tick_timer  = 0.2
								self.tnt_mod_state = 1
								self.object:set_texture_mod("^[colorize:white:130")
							end
						end
					elseif self.attack_type == "projectile" then
						if not self.projectile_timer then
							self.projectile_timer = self.projectile_timer_cooldown
						end
						if self.projectile_timer <= 0 then
							self.projectile_timer = self.projectile_timer_cooldown
							
							local obj = minetest.add_entity(vector.new(pos.x,pos.y+self.object:get_properties().collisionbox[5],pos.z), self.projectile_type)
							if obj then
								local dir = vector.multiply(vector.direction(pos,vector.new(pos2.x,pos2.y-3,pos2.z)), 50)
								obj:set_velocity(dir)
								obj:get_luaentity().timer = 2
								obj:get_luaentity().owner = self.object
							end
						end
					end
					--smart
					if self.path_data and table.getn(self.path_data) > 0 then
						self.direction = vector.direction(vector.new(pos.x,0,pos.z), vector.new(self.path_data[1].x,0,self.path_data[1].z))
					--dumb
					else
						self.direction = vector.direction(vector.new(pos.x,0,pos.z),vector.new(pos2.x,0,pos2.z))
					end
					self.speed = self.max_speed
					self.following = true
				end
				--only look at one player
				break
			end
		end
		--stare straight if not found
		if player_found == false then
			if self.move_head then
				self.move_head(self,nil,dtime)
			end
			if self.following_pos then
				self.following_pos = nil
			end
			if self.manage_hostile_timer then
				self.manage_hostile_timer(self,dtime)
			end
		end
	end
	
	return(mob_register)
end