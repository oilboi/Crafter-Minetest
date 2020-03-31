local arrow = {}
arrow.initial_properties = {
	physical = true,
	collide_with_objects = true,
	collisionbox = {-0.37, -0.4, -0.37, 0.37, 0.5, 0.37},
	visual = "mesh",
	visual_size = {x = 1 , y = 1},
	mesh = "arrow.x",
	textures = {
		"arrow_core.png","front_alpha.png","front_alpha.png"
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

arrow.on_step = function(self, dtime)
	local pos = self.object:get_pos()
	if self.old_pos then
		local yaw = minetest.dir_to_yaw(vector.direction(pos,self.old_pos))+(math.pi/2)
		
		self.object:set_yaw(yaw)
		
		local triangle = vector.new(vector.distance(pos,self.old_pos),0,self.old_pos.y-pos.y)
				
		local tri_yaw = minetest.dir_to_yaw(triangle)+(math.pi/2)
		
		pitch = radians_to_degrees(tri_yaw)
		
		pitch = 90-(math.floor(pitch + 0.5)*2)
		
		self.object:set_animation({x=pitch,y=pitch}, 15, 0, true)
	end
	self.old_pos = pos
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
