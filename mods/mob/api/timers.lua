mobs.create_timer_functions = function(def,mob_register)
	--this controls how fast the mob punches
	mob_register.manage_punch_timer = function(self,dtime)
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
	if def.hostile == true or def.attacked_hostile == true then
		if def.hostile_cooldown == true then
			mob_register.manage_hostile_timer = function(self,dtime)
				if self.hostile_timer > 0 then
					self.hostile_timer = self.hostile_timer - dtime
				end
				if self.hostile_timer <= 0 then
					self.hostile = false
				end
			end
		end
	end

	mob_register.manage_hurt_color_timer = function(self,dtime)
		if self.hurt_color_timer > 0 then
			self.hurt_color_timer = self.hurt_color_timer - dtime
			if self.hurt_color_timer  <= 0 then
				self.hurt_color_timer = 0
				self.object:set_texture_mod("")
			end
		end
	end

	mob_register.manage_explode_timer = function(self,dtime)
		self.tnt_timer = self.tnt_timer - dtime
		self.tnt_tick_timer = self.tnt_tick_timer  - dtime
		if self.tnt_tick_timer <= 0 and not self.dead then
			self.tnt_tick_timer = 0.2
			self.tnt_mod_state = math.abs(self.tnt_mod_state-1)
			if self.tnt_mod_state == 0 then
				self.object:set_texture_mod("")
			else
				self.object:set_texture_mod("^[colorize:"..self.explosion_blink_color..":130")
			end
			--print(self.object:get_texture_mod())
			--self.object:set_texture_mod("^[colorize:red:130")
		end
		if self.tnt_timer <= 0 and not self.dead then
			
			self.object:set_texture_mod("^[colorize:red:130")
			
			local pos = self.object:get_pos()
			--direction.y = direction.y + 1
			
			tnt(pos,self.explosion_power)
			self.death_animation_timer = 1
			self.dead = true
			self.tnt_timer = 100
		end
	end

	mob_register.manage_projectile_timer = function(self,dtime)
		self.projectile_timer = self.projectile_timer - dtime
	end

	--this stops the pig from flying into the air
	mob_register.manage_jump_timer = function(self,dtime)
		if self.jump_timer > 0 then
			self.jump_timer = self.jump_timer - dtime
		end
	end
	return(mob_register)
end
