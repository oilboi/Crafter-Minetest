--this is the file which houses the functions that control how mobs interact with the world


--the sword wear mechanic
slime.add_sword_wear = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
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
slime.do_critical_particles = function(pos)
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
		texture = "critical.png",
	})
end

--this controls what happens when the mob gets punched
slime.on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
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
	
	if (self.punched_timer <= 0 and hp > 1) or puncher == self.object then
		self.hostile = true
		self.hostile_timer = 20
		self.punched_timer = 0.8
		
		if hp > 1 then
			minetest.sound_play("slime_splat", {object=self.object, gain = 1.0, max_hear_distance = 60,pitch = math.random(80,100)/100})
		end
		
		self.hp = hp
		
		self.direction = vector.multiply(dir,-1)
		dir = vector.multiply(dir,10)
		if vel.y <= 0 then
			dir.y = 4
		else
			dir.y = 0
		end
		
		--critical effect
		if critical == true then
			self.do_critical_particles(pos)
		end
		
		self.object:add_velocity(dir)
		self.add_sword_wear(self, puncher, time_from_last_punch, tool_capabilities, dir)
	elseif self.punched_timer <= 0 and self.death_animation_timer == 0 then
		--critical effect
		if critical == true then
			self.do_critical_particles(pos)
		end
		self.death_animation_timer = 1
		self.dead = true
		minetest.sound_play("slime_die", {object=self.object, gain = 1.0, max_hear_distance = 60,pitch = math.random(80,100)/100})
		self.object:set_texture_mod("^[colorize:red:130")
		--self.child:set_texture_mod("^[colorize:red:90")
		self.add_sword_wear(self, puncher, time_from_last_punch, tool_capabilities, dir)
	end
end

--this is what happens when a mob diese
slime.on_death = function(self, killer)
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
	local obj = minetest.add_item(pos,"mob:slimeball")
	self.object:remove()
end

--this makes the mob rotate and then die
slime.manage_death_animation = function(self,dtime)
	if self.death_animation_timer >= 0 and self.dead == true then
		self.death_animation_timer = self.death_animation_timer - dtime
		
		local self_rotation = self.object:get_rotation()
		
		if self_rotation.x < math.pi/2 then
			self_rotation.x = self_rotation.x + (dtime*2)
			self.object:set_rotation(self_rotation)
		end
		
		--print(self.death_animation_timer)
		local currentvel = self.object:getvelocity()
		local goal = vector.new(0,0,0)
		local acceleration = vector.new(goal.x-currentvel.x,0,goal.z-currentvel.z)
		acceleration = vector.multiply(acceleration, 0.05)
		self.object:add_velocity(acceleration)
		self.object:set_animation({x=0,y=0}, 15, 0, true)
		
		if self.death_animation_timer <= 0 then
			self.on_death(self)
		end
	end
end

--the slime will look for and attack players
slime.look_around = function(self,dtime)
	local pos = self.object:get_pos()

	self.following = false
	local player_found = false
	for _,object in ipairs(minetest.get_objects_inside_radius(pos, 6)) do
		if object:is_player() and player_found == false and object:get_hp() > 0 then
			--look at player's camera
			local pos2 = object:get_pos()
			pos2.y = pos2.y + 1.625
			
			player_found = true
			
			if self.hostile == true then
				self.direction = vector.direction(pos,pos2)
				local distance = vector.distance(pos,pos2)-2
				
				if distance < 0 then
					distance = 0
				end
				
				local vel = self.object:get_velocity()
				--punch the player
				if vel.y ~= 0 and distance < 1 and self.punch_timer <= 0 and object:get_hp() > 0 then
					self.punch_timer = 1
					object:punch(self.object, 2, 
						{
						full_punch_interval=1.5,
						damage_groups = {fleshy=2},
					},vector.direction(pos,pos2))
				end
				self.speed = distance * 3
				self.following = true
			end
			--only look at one player
			break
		end
	end
end
