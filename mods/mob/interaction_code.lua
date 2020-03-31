--this is the file which houses the functions that control how mobs interact with the world

--this controls how fast the mob punches
mob.manage_punch_timer = function(self,dtime)
	if self.punch_timer > 0 then
		self.punch_timer = self.punch_timer - dtime
	end
end


--this controls what happens when the mob gets punched
mob.on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
	print(time_from_last_punch)
	local hurt = tool_capabilities.damage_groups.fleshy
	if not hurt then
		hurt = 1
	end
	local hp = self.object:get_hp()
	self.object:set_hp(hp-hurt)
	if hp > 1 then
		minetest.sound_play("hurt", {object=self.object, gain = 1.0, max_hear_distance = 60,pitch = math.random(80,100)/100})
	end
	self.hp = hp-hurt
	
	dir = vector.multiply(dir,10)
	dir.y = 4
	self.object:add_velocity(dir)
end
