-- 
mobs.create_animation_functions = function(def,mob_register)
	if def.movement_type ~= "jump" then
		mob_register.set_animation = function(self)
			if self.speed == 0 or vector.equals(self.direction,vector.new(0,0,0)) then
				self.current_animation = 0
				self.object:set_animation(def.standing_frame, 1, 0, true)
			else
				if self.current_animation ~= 1 then
					self.object:set_animation(def.moving_frame, 1, 0, true)
					self.current_animation = 1
				end
				
				local speed = self.object:get_velocity()
				speed.y = 0
				self.object:set_animation_frame_speed(vector.distance(vector.new(0,0,0),speed)*def.animation_multiplier)
			end
		end
	end

	--this makes the mob rotate and then die
	mob_register.manage_death_animation = function(self,dtime)
		if self.death_animation_timer >= 0 and self.dead == true then
			self.death_animation_timer = self.death_animation_timer - dtime
			
			local self_rotation = self.object:get_rotation()
			
			if self.death_rotation == "x" then
				if self_rotation.x < math.pi/2 then
					self_rotation.x = self_rotation.x + (dtime*2)
					self.object:set_rotation(self_rotation)
				end
			elseif self.death_rotation == "z" then
				if self_rotation.z < math.pi/2 then
					self_rotation.z = self_rotation.z + (dtime*2)
					self.object:set_rotation(self_rotation)
				end
			end
			
			--print(self.death_animation_timer)
			local currentvel = self.object:get_velocity()
			local goal = vector.new(0,0,0)
			local acceleration = vector.new(goal.x-currentvel.x,0,goal.z-currentvel.z)
			acceleration = vector.multiply(acceleration, 0.05)
			self.object:add_velocity(acceleration)
			self.object:set_animation(def.standing_frame, 15, 0, true)
		end
	end
	return(mob_register)
end
