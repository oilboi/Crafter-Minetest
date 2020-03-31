--this is the file which houses the functions that control how mobs interact with the world

--this controls how fast the mob punches
mob.manage_punch_timer = function(self,dtime)
	if self.punch_timer > 0 then
		self.punch_timer = self.punch_timer - dtime
	end
	--this controls how fast you can punch the mob (punched timer reset)
	if self.punched_timer > 0 then
		print(self.punched_timer)
		self.punched_timer = self.punched_timer - dtime
	end
end


--this controls what happens when the mob gets punched
mob.on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
	local hp = self.object:get_hp()
	
	if (self.punched_timer <= 0 and hp > 1) or puncher == self.object then
		self.punched_timer = 0.8
		local hurt = tool_capabilities.damage_groups.fleshy
		if not hurt then
			hurt = 1
		end
		
		self.object:set_hp(hp-hurt)
		if hp > 1 then
			minetest.sound_play("pig", {object=self.object, gain = 1.0, max_hear_distance = 60,pitch = math.random(80,100)/100})
		end
		
		self.hp = hp-hurt
		

		self.direction = vector.multiply(dir,-1)
		self.speed = 5

		dir = vector.multiply(dir,10)
		dir.y = 4
		self.object:add_velocity(dir)
	elseif self.punched_timer <= 0 and self.death_animation_timer == 0 then
		self.death_animation_timer = 1
		minetest.sound_play("pig_die", {object=self.object, gain = 1.0, max_hear_distance = 60,pitch = math.random(80,100)/100})
	end
end

--this is what happens when a mob diese
mob.on_death = function(self, killer)
	local pos = self.object:getpos()
	pos.y = pos.y + 0.4
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
	local obj = minetest.add_item(pos,"mob:raw_porkchop")
	self.child:get_luaentity().parent = nil
end

--this makes the mob rotate and then die
mob.manage_death_animation = function(self,dtime)
	if self.death_animation_timer > 0 then
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
		self.return_head_to_origin(self)
		
		if self.death_animation_timer < 0 then
			print("dead")
			self.object:punch(self.object, 2, 
						{
						full_punch_interval=1.5,
						damage_groups = {fleshy=2},
					})
		end
	end
end
