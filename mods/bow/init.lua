local arrow = {}
arrow.initial_properties = {
	physical = true,
	collide_with_objects = false,
	collisionbox = {-0.05, -0.05, -0.05, 0.05, 0.05, 0.05},
	visual = "mesh",
	visual_size = {x = 1 , y = 1},
	mesh = "basic_bow_arrow.b3d",
	textures = {
		"basic_bow_arrow_uv.png"
	},
	pointable = true,
	glow = -1,
	--automatic_face_movement_dir = 0.0,
	--automatic_face_movement_max_rotation_per_sec = 600,
}
arrow.on_activate = function(self, staticdata, dtime_s)
	--self.object:set_animation({x=0,y=180}, 15, 0, true)
	if string.sub(staticdata, 1, string.len("return")) == "return" then
		local data = minetest.deserialize(staticdata)
		if data and type(data) == "table" then
			self.spin = data.spin
			self.owner = data.owner
			self.stuck = data.stuck
			self.timer = data.timer
			self.collecting = data.collecting
		end
	end
	if not self.stuck then
		self.object:set_acceleration(vector.new(0,-9.81,0))
	end
end

arrow.get_staticdata = function(self)
	return minetest.serialize({
		spin = self.spin,
		owner = self.owner,
		stuck = self.stuck,
		timer = self.timer,
		collecting = self.collecting
	})
end

local radians_to_degrees = function(radians)
	return(radians*180.0/math.pi)
end
arrow.spin = 0
arrow.owner = ""
arrow.stuck = false
arrow.timer = 0
arrow.collecting = false
arrow.collection_height = 0.5
arrow.radius = 2
arrow.on_step = function(self, dtime,moveresult)
	local pos = self.object:get_pos()
    local vel = self.object:get_velocity()
	self.timer = self.timer + dtime
	
	if self.collecting == true then
		for _,object in ipairs(minetest.get_objects_inside_radius(pos, self.radius)) do
			local owner = minetest.get_player_by_name(self.owner)
			if owner then
				self.object:setacceleration(vector.new(0,0,0))
				--get the variables
				local pos2 = owner:get_pos()
				local player_velocity = owner:get_player_velocity()
				pos2.y = pos2.y + self.collection_height
								
				local direction = vector.normalize(vector.subtract(pos2,pos))
				local distance = vector.distance(pos2,pos)
								
				
				--remove if too far away
				if distance > self.radius then
					distance = 0
				end
								
				local multiplier = (self.radius*5) - distance
				local velocity = vector.multiply(direction,multiplier)
				
				local velocity = vector.add(player_velocity,velocity)
				
				self.object:setvelocity(velocity)
				
				if distance < 0.2 then
					self.object:remove()
				end
				
				
				--self.delete_timer = self.delete_timer + dtime
				--this is where the item gets removed from world
				--if self.delete_timer > 1 then
				--	self.object:remove()
				--end
				return
			else
				print(self.owner.." does not exist")
				self.object:remove()
			end
		end
	else
		for _,object in ipairs(minetest.get_objects_inside_radius(pos, 2)) do
			if (object:is_player() and object:get_player_name() ~= self.owner and object:get_hp() > 0) or (object:get_luaentity() and object:get_luaentity().mob == true) then
				object:punch(self.object, 2, 
					{
					full_punch_interval=1.5,
					damage_groups = {damage=3},
				})
				hit = true
				self.object:remove()
				break
			elseif self.timer > 3 and (object:is_player() and object:get_player_name() == self.owner) then
				self.collecting = true
				local inv = object:get_inventory()
				if inv and inv:room_for_item("main", ItemStack("bow:arrow")) then
					inv:add_item("main",ItemStack("bow:arrow"))
					minetest.sound_play("pickup", {
						to_player = object:get_player_name(),
						gain = 0.4,
						pitch = math.random(60,100)/100
					})
				else
					self.object:remove()
					minetest.throw_item(pos,"bow:arrow")
				end
			end
		end

		if moveresult and moveresult.collides and self.stuck == false then

			if moveresult.collisions[1].new_velocity.x == 0 and moveresult.collisions[1].old_velocity.x ~= 0 then
				self.check_dir = vector.direction(vector.new(pos.x,0,0),vector.new(moveresult.collisions[1].node_pos.x,0,0))
			elseif moveresult.collisions[1].new_velocity.y == 0 and moveresult.collisions[1].old_velocity.y ~= 0 then
				self.check_dir = vector.direction(vector.new(0,pos.y,0),vector.new(0,moveresult.collisions[1].node_pos.y,0))
			elseif moveresult.collisions[1].new_velocity.z == 0 and moveresult.collisions[1].old_velocity.z ~= 0 then
				self.check_dir = vector.direction(vector.new(0,0,pos.z),vector.new(0,0,moveresult.collisions[1].node_pos.z))
			end

			minetest.sound_play("arrow_hit",{object=self.object,gain=1,pitch=math.random(80,100)/100,max_hear_distance=64})
			self.stuck = true
			self.object:set_velocity(vector.new(0,0,0))
			self.object:set_acceleration(vector.new(0,0,0))
		elseif self.stuck == true and self.check_dir then
			local pos2 = vector.add(pos,vector.multiply(self.check_dir,0.2))

			minetest.add_particle({
				pos = pos2,
				velocity = {x=0, y=0, z=0},
				acceleration = {x=0, y=0, z=0},
				expirationtime = 0.2,
				size = 1,
				texture = "dirt.png",
			})
			
			local ray = minetest.raycast(pos, pos2, false, false)
			local pointed_thing = ray:next()

			if not pointed_thing then
				self.stuck = false
				self.object:set_acceleration(vector.new(0,-9.81,0))
			end
		end
		
		if not self.stuck and pos and self.oldpos then
			self.spin = self.spin + (dtime*10)
			if self.spin > math.pi then
				self.spin = -math.pi
			end

			local dir = vector.normalize(vector.subtract(pos,self.oldpos))
			local y = minetest.dir_to_yaw(dir)
			local x = (minetest.dir_to_yaw(vector.new(vector.distance(vector.new(pos.x,0,pos.z),vector.new(self.oldpos.x,0,self.oldpos.z)),0,pos.y-self.oldpos.y))+(math.pi/2))
			self.object:set_rotation(vector.new(x,y,self.spin))
			--local frame = self.get_animation_frame(dir)
			--self.object:set_animation({x=frame, y=frame}, 0)
		end
		if self.stuck == false then
			self.oldpos = pos
			self.oldvel = vel
		end
	end
end
minetest.register_entity("bow:arrow", arrow)


minetest.register_craftitem("bow:bow_empty", {
	description = "Bow",
	inventory_image = "bow.png",
	stack_max = 1,
	groups = {bow=1}
})

for i = 1,5 do
	minetest.register_craftitem("bow:bow_"..i, {
		description = "Bow",
		inventory_image = "bow_"..i..".png",
		stack_max = 1,
		groups = {bow=1,bow_loaded=i}
	})
end

minetest.register_craftitem("bow:arrow", {
	description = "Arrow",
	inventory_image = "arrow_item.png",
})

minetest.register_globalstep(function(dtime)
	--check if player has bow
	for _,player in ipairs(minetest.get_connected_players()) do
		local item = player:get_wielded_item():get_name()
		if minetest.get_item_group(item, "bow") > 0 then
			--begin to pull the bow back
			if player:get_player_control().RMB == true then
					local meta = player:get_meta()
					local animation = meta:get_float("bow_loading_animation")
					
					if animation <= 5 then
					
						if animation == 0 then
							animation = 1
							player:set_wielded_item(ItemStack("bow:bow_1"))
						end
						animation = animation + (dtime*2)
						
						--print(animation)
						
						meta:set_float("bow_loading_animation", animation)
						
						local level = minetest.get_item_group(item, "bow_loaded")
						
						
						local new_level = math.floor(animation + 0.5)
						
						--print(new_level,level)
						
						if new_level > level then
							if level > 0 then
								minetest.sound_play("bow_pull_back", {object=player, gain = 1.0, max_hear_distance = 60,pitch = 0.7+new_level*0.1})
							end
							player:set_wielded_item(ItemStack("bow:bow_"..new_level))
						end
					end
					
					--player:set_wielded_item(ItemStack("main:glass"))
			else
				local power = minetest.get_item_group(item, "bow_loaded")
				
				if power > 0 then
					local dir = player:get_look_dir()
					local vel = vector.multiply(dir,power*10)
					local pos = player:get_pos()
					pos.y = pos.y + 1.625
					local object = minetest.add_entity(pos,"bow:arrow")
					object:set_velocity(vel)
					object:get_luaentity().owner = player:get_player_name()
					minetest.sound_play("bow", {object=player, gain = 1.0, max_hear_distance = 60,pitch = math.random(80,100)/100})
				end
			
				player:set_wielded_item(ItemStack("bow:bow_empty"))
				local meta = player:get_meta()
				meta:set_float("bow_loading_animation", 0)
			end
		end
	end
end)
