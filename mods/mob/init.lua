--this is where mobs are defined

--this is going to be used to set an active mob limit
global_mob_table = {}


local path = minetest.get_modpath(minetest.get_current_modname())

dofile(path.."/spawning.lua")
dofile(path.."/items.lua")


--these are helpers to create entities
mob = {}

dofile(path.."/head_code.lua")
dofile(path.."/movement_code.lua")
dofile(path.."/data_handling_code.lua")
dofile(path.."/interaction_code.lua")

mob.initial_properties = {
	hp_max = 1,
	physical = true,
	collide_with_objects = false,
	collisionbox = {-0.37, -0.4, -0.37, 0.37, 0.5, 0.37},
	visual = "mesh",
	visual_size = {x = 3, y = 3},
	mesh = "pig.x",
	textures = {
		"body.png","leg.png","leg.png","leg.png","leg.png"
	},
	is_visible = true,
	pointable = true,
	automatic_face_movement_dir = 0.0,
	automatic_face_movement_max_rotation_per_sec = 300,
}

mob.hp = 5
mob.speed = 5

mob.death_animation_timer = 0

mob.mob = true
mob.hostile = false
mob.timer = 0
mob.state = 0
mob.hunger = 200
mob.view_distance = 20

mob.punch_timer = 0
mob.punched_timer = 0
----------------------------------


--repel from players
mob.push = function(self)
	local pos = self.object:getpos()
	local radius = 1
	for _,object in ipairs(minetest.get_objects_inside_radius(pos, radius)) do
		if object:is_player() or object:get_luaentity().mob == true then
			local player_pos = object:getpos()
			pos.y = 0
			player_pos.y = 0
			
			local currentvel = self.object:getvelocity()
			local vel = vector.subtract(pos, player_pos)
			vel = vector.normalize(vel)
			local distance = vector.distance(pos,player_pos)
			distance = (radius-distance)*10
			vel = vector.multiply(vel,distance)
			local acceleration = vector.new(vel.x-currentvel.x,0,vel.z-currentvel.z)
			
			
			self.object:add_velocity(acceleration)
			
			acceleration = vector.multiply(acceleration, 5)
			object:add_player_velocity(acceleration)
		end
	end
end


--makes the mob swim
mob.swim = function(self)
	local pos = self.object:getpos()
	pos.y = pos.y + 0.7
	local node = minetest.get_node(pos).name
	local vel = self.object:getvelocity()
	local goal = 3
	local acceleration = vector.new(0,goal-vel.y,0)
	self.swimming = false
	
	if node == "main:water" or node =="main:waterflow" then
		self.swimming = true
		self.object:add_velocity(acceleration)
	end
end

--sets the mob animation and speed
mob.set_animation = function(self)
	local distance = vector.distance(vector.new(0,0,0), self.object:getvelocity())
	self.object:set_animation_frame_speed(distance*5)
end





mob.look_around = function(self)
	local pos = self.object:get_pos()
	
	--this is where the mob is actually looking
	local eye_ray = self.raycast_look(self,dtime)
	--this is below where the mob is pointed, checks if ledge
	--[[ --work on this later
	local ledge_ray = self.look_below(self)
		
	local is_a_drop = true
	--check if there's a drop
	if ledge_ray then
		for pointed_thing in ledge_ray do
			if pointed_thing then
				local pos2 = pointed_thing.under
				local distance = math.floor(vector.subtract(pos2,pos).y-self.object:get_properties().collisionbox[2]+0.5+0.5)
				if distance >= -3 then
					is_a_drop = false
				end
			end
		end
	end
	--turn around
	if is_a_drop == true then
		self.direction = vector.multiply(self.direction, -1)
		print("turning around")
	end
	]]--
	
	--a mob will check if it needs to jump
	if eye_ray then
		for pointed_thing in eye_ray do
			local pos = self.object:get_pos()
			local pos2 = pointed_thing.under
			local walkable
			if minetest.registered_nodes[minetest.get_node(pos2).name] then
				walkable = minetest.registered_nodes[minetest.get_node(pos2).name].walkable
			end
			if walkable then
				if vector.distance(pos,pos2) < 1 then
					self.jump(self)
					break
				end
			end
		end
	end
	
	
	--STARE O_O
	--and follow!
	self.following = false
	local player_found = false
	for _,object in ipairs(minetest.get_objects_inside_radius(pos, 6)) do
		if object:is_player() and player_found == false then
			--print("test")
			player_found = true
			--look at player's camera
			local pos2 = object:get_pos()
			pos2.y = pos2.y + 1.625
			
			local found_player = self.move_head(self,pos2)
			
			if found_player == true then
				self.direction = vector.direction(pos,pos2)
				local distance = vector.distance(pos,pos2)-2
				if distance < 0 then
					distance = 0
				end
				
				--punch the player
				if distance < 0.5 and self.punch_timer <= 0 and object:get_hp() > 0 then
					self.punch_timer = 1
					object:punch(self.object, 2, 
						{
						full_punch_interval=1.5,
						damage_groups = {fleshy=2},
					},vector.direction(pos,pos2))
				elseif distance < 0.5 and object:get_hp() <= 0 then
					--make the head spin "victory dance"
					if self.child then
						if not self.head_spin then
							self.head_spin = 180
						end
						self.child:set_attach(self.object, "", vector.new(2.4,1.2,0), vector.new(self.head_spin,0,0))
						self.child:set_animation({x=90,y=90}, 15, 0, true)
						self.head_spin = self.head_spin + 5
						if self.head_spin > 360 then
							self.head_spin = 0
						end
					end
				end
				self.speed = distance * 2
				self.following = true
				break
			end
		end
	end
	
	
	
	--stare straight if not found
	if player_found == false then
		self.move_head(self,nil)
	end
	
end
--this is the info on the mob
mob.debug_nametag = function(self,dtime)
	--we're doing this to the child because the nametage breaks the
	--animation on the mob's body
	if self.child then
		--we add in items we want to see in this list
		local debug_items = {"hunger","timer","punch_timer","yaw"}
		local text = ""
		for _,item in pairs(debug_items) do
			if self[item] then
				text = text..item..": "..self[item].."\n"
			end
		end
		self.child:set_nametag_attributes({
		color = "white",
		text = text
		})
	end
end

--this depletes the mobs hunger
mob.do_hunger = function(self,dtime)
	self.hunger = self.hunger - dtime
end

--this sets the state of the mob
mob.set_state = function(self,dtime)
	self.do_hunger(self,dtime)
end

mob.on_step = function(self, dtime)
	if self.death_animation_timer == 0 then
		self.set_state(self,dtime)
		self.move(self,dtime)
		self.set_animation(self)
		self.look_around(self)
		self.manage_punch_timer(self,dtime)
		mob.debug_nametag(self,dtime)
	end
	self.manage_death_animation(self,dtime)
end

minetest.register_entity("mob:pig", mob)





------------------------------------------------------------------------the head

local head = {}
head.initial_properties = {
	hp_max = 1,
	physical = false,
	collide_with_objects = false,
	collisionbox = {0, 0, 0, 0, 0, 0},
	visual = "mesh",
	visual_size = {x = 1.1, y = 1.1},
	mesh = "pig_head.x",
	textures = {
		"head.png","nose.png"
	},
	is_visible = true,
	pointable = false,
	--automatic_face_movement_dir = 0.0,
	--automatic_face_movement_max_rotation_per_sec = 600,
}

--remove the head if no body
head.on_step = function(self, dtime)
	if self.parent == nil then
		self.object:remove()
	end
end
minetest.register_entity("mob:head", head)
