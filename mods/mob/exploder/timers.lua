--this is where all the pig's timers are!

--this controls how fast the mob punches
exploder.manage_punch_timer = function(self,dtime)
	if self.punch_timer > 0 then
		self.punch_timer = self.punch_timer - dtime
	end
	--this controls how fast you can punch the mob (punched timer reset)
	if self.punched_timer > 0 then
		--print(self.punched_timer)
		self.punched_timer = self.punched_timer - dtime
	end
end

--this controls the hostile state
exploder.manage_hostile_timer = function(self,dtime)
	if self.hostile_timer > 0 then
		self.hostile_timer = self.hostile_timer - dtime
	end
	if self.hostile_timer <= 0 then
		self.hostile = false
	end
end

--this stops the pig from flying into the air
exploder.manage_jump_timer = function(self,dtime)
	if self.jump_timer > 0 then
		self.jump_timer = self.jump_timer - dtime
	end
end
