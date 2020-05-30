--
mobs.create_data_handling_functions = function(def,mob_register)
	mob_register.get_staticdata = function(self)
		return minetest.serialize({
			--range = self.range,
			hp = self.hp,
			hunger = self.hunger,
			hostile = self.hostile,
			hostile_timer = self.hostile_timer,
			death_animation_timer = self.death_animation_timer,
			dead = self.dead,
			tnt_timer = self.tnt_timer,
			tnt_tick_timer = self.tnt_tick_timer,
			tnt_mod_state = self.tnt_mod_state,
			punch_timer = self.punch_timer,
			projectile_timer = self.projectile_timer
		})
	end


	mob_register.on_activate = function(self, staticdata, dtime_s)
		global_mob_amount = global_mob_amount + 1
		--print("Mobs Spawned. Current Mobs: "..global_mob_amount)
		self.object:set_armor_groups({immortal = 1})
		--self.object:set_velocity({x = math.random(-5,5), y = 5, z = math.random(-5,5)})
		self.object:set_acceleration(def.gravity)
		if string.sub(staticdata, 1, string.len("return")) == "return" then
			local data = minetest.deserialize(staticdata)
			if data and type(data) == "table" then
				--self.range = data.range
				self.hp = data.hp
				self.hunger = data.hunger
				self.hostile = data.hostile
				self.hostile_timer = data.hostile_timer
				self.death_animation_timer = data.death_animation_timer
				self.dead = data.dead
				self.tnt_timer = data.tnt_timer
				self.tnt_tick_timer = data.tnt_tick_timer
				self.tnt_mod_state = data.tnt_mod_state
				self.punch_timer = data.punch_timer
				self.projectile_timer = data.projectile_timer
			end
		end
		
		--set up mob
		self.object:set_animation(def.standing_frame, 0, 0, true)
		self.current_animation = 0
		self.object:set_hp(self.hp)
		self.direction = vector.new(math.random()*math.random(-1,1),0,math.random()*math.random(-1,1))
		
		
		--set the head up
		if self.head_bone then
			self.object:set_bone_position(self.head_bone, self.head_position_correction, vector.new(0,0,0))
		end
		self.is_mob = true
		self.object:set_armor_groups({immortal = 1})
		if self.custom_on_activate then
			self.custom_on_activate(self)
		end
		--self.object:set_yaw(math.pi*math.random(-1,1)*math.random())
	end

	--this is the info on the mob
	mob_register.debug_nametag = function(self,dtime)
		--we're doing this to the child because the nametage breaks the
		--animation on the mob's body
		
		--we add in items we want to see in this list
		local debug_items = {"hostile","hostile_timer"}
		local text = ""
		for _,item in pairs(debug_items) do
			if self[item] ~= nil then
				text = text..item..": "..tostring(self[item]).."\n"
			end
		end
		self.object:set_nametag_attributes({
		color = "white",
		text = text
		})
	end
	return(mob_register)
end
