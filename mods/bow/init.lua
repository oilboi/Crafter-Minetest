local arrow = {}
arrow.initial_properties = {
	physical = true,
	collide_with_objects = false,
	collisionbox = {-0.37, -0.4, -0.37, 0.37, 0.5, 0.37},
	visual = "mesh",
	visual_size = {x = 1 , y = 1},
	mesh = "basic_bow_arrow.b3d",
	textures = {
		"basic_bow_arrow_uv.png"
	},
	pointable = false,
	glow = -1,
	--automatic_face_movement_dir = 0.0,
	--automatic_face_movement_max_rotation_per_sec = 600,
}
arrow.on_activate = function(self, staticdata, dtime_s)
	--self.object:set_animation({x=0,y=180}, 15, 0, true)
	self.object:set_acceleration(vector.new(0,-9.81,0))
end

local radians_to_degrees = function(radians)
	return(radians*180.0/math.pi)
end
arrow.spin = 0
arrow.on_step = function(self, dtime)
	local pos = self.object:get_pos()
    local vel = self.object:get_velocity()
	self.spin = self.spin + (dtime*10)
	if self.spin > math.pi then
		self.spin = -math.pi
	end
    for _,object in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
		if (object:is_player() and object:get_hp() > 0 and object:get_player_name() ~= self.thrower) or (object:get_luaentity() and object:get_luaentity().mob == true) then
            if object:is_player() then
                object:punch(self.object, 2, 
                    {
                    full_punch_interval=1.5,
                    damage_groups = {fleshy=3},
                })
            else
                object:punch(self.object, 2, 
                    {
                    full_punch_interval=1.5,
                    damage_groups = {damage=3},
                })
            end
			hit = true
            self.object:remove()
			break
		end
	end
    
	if (self.oldvel and ((vel.x == 0 and self.oldvel.x ~= 0) or (vel.z == 0 and self.oldvel.z ~= 0) or (vel.y == 0 and self.oldvel.y ~= 0))) then
		--self.object:set_velocity(vector.new(0,0,0))
		--self.object:set_acceleration(vector.new(0,0,0))
		minetest.sound_play("arrow_hit",{object=self.object,gain=1,pitch=math.random(80,100)/100,max_hear_distance=64})
        minetest.throw_item(pos, "bow:arrow")
        self.object:remove()
    end
	
	if pos and self.oldpos then
		local dir = vector.normalize(vector.subtract(pos,self.oldpos))
		local y = minetest.dir_to_yaw(dir)
		local x = (minetest.dir_to_yaw(vector.new(vector.distance(vector.new(pos.x,0,pos.z),vector.new(self.oldpos.x,0,self.oldpos.z)),0,pos.y-self.oldpos.y))+(math.pi/2))
		self.object:set_rotation(vector.new(x,y,self.spin))
		--local frame = self.get_animation_frame(dir)
		--self.object:set_animation({x=frame, y=frame}, 0)
	end
	self.oldpos = pos
    self.oldvel = vel
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
					minetest.sound_play("bow", {object=player, gain = 1.0, max_hear_distance = 60,pitch = math.random(80,100)/100})
				end
			
				player:set_wielded_item(ItemStack("bow:bow_empty"))
				local meta = player:get_meta()
				meta:set_float("bow_loading_animation", 0)
			end
		end
	end
end)
