local do_smoke_dust = function(pos,pos2)
	local distance = vector.distance(pos,pos2)
	local dir = vector.divide(vector.direction(pos, pos2),2)
	local pos_step = table.copy(pos)
	local steps = math.floor(distance + 0.5)*2
	
	for i = 1,steps do
		local expire = (i/steps) * steps/100
	
		pos_step = vector.add(pos_step,dir)
		--minetest.add_item(pos_step,"main:glass")
		minetest.add_particle({
        pos = pos_step,
        velocity = {x=0, y=0, z=0},
        acceleration = {x=0, y=0, z=0},
        -- Spawn particle at pos with velocity and acceleration

        expirationtime = expire,
        -- Disappears after expirationtime seconds

        size = 1,
        -- Scales the visual size of the particle texture.

        collisiondetection = false,
        -- If true collides with `walkable` nodes and, depending on the
        -- `object_collision` field, objects too.

        collision_removal = false,
        -- If true particle is removed when it collides.
        -- Requires collisiondetection = true to have any effect.

        object_collision = false,
        -- If true particle collides with objects that are defined as
        -- `physical = true,` and `collide_with_objects = true,`.
        -- Requires collisiondetection = true to have any effect.

        vertical = false,
        -- If true faces player using y axis only

        texture = "smoke.png",

        playername = "singleplayer",
        -- Optional, if specified spawns particle only on the player's client
    })
	end

end

minetest.register_craftitem("gun:gun", {
	description = "Gun",
	inventory_image = "gun.png",
	stack_max = 1,
	range = 0,
	on_use = function(itemstack, user, pointed_thing)
		minetest.sound_play("reload_gun",{object=user, pitch = math.random(80,100)/100})
		print("reload")
	end,
	
	on_secondary_use = function(itemstack, user, pointed_thing)
		local pos = user:get_pos()
		pos.y = pos.y + 1.625
		minetest.sound_play("gun_shot",{object=user, pitch = math.random(80,100)/100})
		local dir = user:get_look_dir()
		local pos2 = vector.add(pos,vector.multiply(dir,100))
		local ray = minetest.raycast(pos, pos2, true, true)

		local shot = false
		if ray then
			for pointed_thing in ray do
				if pointed_thing.type == "node" then
					local walkable = minetest.registered_nodes[minetest.get_node(pointed_thing.under).name].walkable
					if walkable then
						shot = true
						local intersect_pos = pointed_thing.intersection_point
						local dir = vector.multiply(pointed_thing.intersection_normal, -0.04)
						minetest.add_entity(vector.add(intersect_pos,dir), "gun:bullet_hole")
						do_smoke_dust(pos,pointed_thing.intersection_point)
						minetest.after(0,function(intersect_pos)
							minetest.sound_play("ricochet",{object=user, pitch = math.random(80,100)/100,max_hear_distance = 32})
						end,intersect_pos)
						break
					end	
				elseif pointed_thing.type == "object" then
					local object = pointed_thing.ref
					if (object:is_player() and object:get_player_name() ~= user:get_player_name()) or not object:is_player() then
						if object and object:get_luaentity() and object:get_luaentity().mob == true then
							local pos2 = object:get_pos()
							--print("shoot the mob")
							object:punch(user, 2, 
								{
								full_punch_interval=1.5,
								damage_groups = {fleshy=2},
							},vector.direction(pos,pos2))
							do_smoke_dust(pos,pointed_thing.intersection_point)
							break
						end
					end
				end
			end
		end
	end,
})


local bullet_hole = {}
bullet_hole.initial_properties = {
	physical = false,
	collide_with_objects = false,
	collisionbox = {0, 0, 0, 0, 0, 0},
	visual = "cube",
	visual_size = {x = 0.1, y = 0.1},
	textures = {
		"bullet_hole.png","bullet_hole.png","bullet_hole.png","bullet_hole.png","bullet_hole.png","bullet_hole.png"
	},
	is_visible = true,
	pointable = false,
	glow = -1,
	--automatic_face_movement_dir = 0.0,
	--automatic_face_movement_max_rotation_per_sec = 600,
}

bullet_hole.on_step = function(self, dtime)
end
minetest.register_entity("gun:bullet_hole", bullet_hole)
