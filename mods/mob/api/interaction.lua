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
		pos.y = pos.y - self.object:get_properties().collisionbox[2]
		for _,object in ipairs(minetest.get_objects_inside_radius(pos, self.collision_boundary)) do
			if object:is_player() or object:get_luaentity().mob == true then
				local pos2 = object:get_pos()
				
				local dir = vector.direction(pos,pos2)
				dir.y = 0
				
				--eliminate mob being stuck in corners
				if dir.x == 0 and dir.z == 0 then
					dir = vector.new(math.random(-1,1)*math.random(),0,math.random(-1,1)*math.random())
				end
				
				local velocity = vector.multiply(dir,1.1)
				
				vel1 = vector.multiply(velocity, -1)
				vel2 = velocity
				self.object:add_velocity(vel1)
				
				if object:is_player() then
					object:add_player_velocity(vel2)
				else
					object:add_velocity(vel2)
				end
			end
		end
	end
	
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
		
		if (self.punched_timer <= 0 and hp > 1) then
			if puncher ~= self.object then
				self.hostile = true
			end
			self.hostile_timer = 20
			self.punched_timer = 0.8
			
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
			self.death_animation_timer = 1
			self.dead = true
			
			--critical effect
			if critical == true then
				self.do_critical_particles(pos)
				minetest.sound_play("critical", {object=self.object, gain = 0.1, max_hear_distance = 10,pitch = math.random(80,100)/100})
			end
			minetest.sound_play(self.die_sound, {object=self.object, gain = 1.0, max_hear_distance = 10,pitch = math.random(80,100)/100})
			
			self.object:set_texture_mod("^[colorize:red:130")
			if self.child then
			self.child:set_texture_mod("^[colorize:red:130") 
			end
			self.add_sword_wear(self, puncher, time_from_last_punch, tool_capabilities, dir)
		end
	end

	--this is what happens when a mob dies
	mob_register.on_death = function(self, killer)
		local pos = self.object:getpos()
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
			if self.item_amount  and self.item_minumum then
				local data_item_amount = math.random(self.item_minimum, self.item_amount)
				for i = self.item_minimum,data_item_amount do
					minetest.throw_item(pos,self.item_drop)
				end
			else
				minetest.throw_item(pos,self.item_drop)
			end
		end
			
		global_mob_amount = global_mob_amount - 1
		print("Mobs Died. Current Mobs: "..global_mob_amount)
		if self.child and self.child:get_luaentity() then
			self.child:get_luaentity().parent = nil
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
				
				
				if self.hostile == true then
					
					self.direction = vector.direction(pos,pos2)
					local distance = vector.distance(pos,pos2)-2
					if distance < 0 then
						distance = 0
					end
					
					--punch the player
					if self.attack_type == "punch" then
						if distance < 1 and self.punch_timer <= 0 and object:get_hp() > 0 then
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
						if distance <  self.explosion_radius then
							
							if not self.tnt_timer then
								minetest.sound_play("tnt_ignite", {object = self.object, gain = 1.0,})
								self.tnt_timer = self.explosion_time
								self.object:set_texture_mod("^[colorize:white:130")
							end
						end
					elseif self.attack_type == "projectile" then
						if not self.projectile_timer then
							self.projectile_timer = self.projectile_timer_cooldown
						end
						if self.projectile_timer <= 0 then
							self.projectile_timer = self.projectile_timer_cooldown
							
							local obj = minetest.add_entity(pos, self.projectile_type)
							if obj then
								local dir = vector.multiply(vector.direction(pos,pos2), 50)
								obj:set_velocity(dir)
								obj:get_luaentity().timer = 2
							end
						end
					end
					self.speed = distance * 4
					if self.speed > self.max_speed then
						self.speed = self.max_speed
					end
					self.following = true
				end
				--only look at one player
				break
			end
		end
		--stare straight if not found
		if player_found == false then
			--self.move_head(self,nil,dtime)
			if self.manage_hostile_timer then
				self.manage_hostile_timer(self,dtime)
			end
		end
	end
	
	return(mob_register)
end
