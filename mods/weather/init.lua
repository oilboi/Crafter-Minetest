--[[
when updating check if the modified node is below the current entity position

or when dug check if below

when placed check if above

if finding node fails and player is under direct sunlight then
do weather effects with the y pos half way down the column of the weather particle spawner



--add all nodes to node list
local all_nodes = {}
minetest.register_on_mods_loaded(function()
	for name in pairs(minetest.registered_nodes) do
		if name ~= "air" and name ~= "ignore" then
			table.insert(all_nodes,name)
		end
	end
end)

local spawn_weather = function(player)
	local pos = player:get_pos()
	local radius = 10
	local meta = player:get_meta()
	local particle_table = {}
	
	local min = vector.subtract(pos, 10)
	local max = vector.add(pos, 10)
	
	
	local area_index = minetest.find_nodes_in_area_under_air(min, max, all_nodes)
	
	
	
	
	local spawn_table = {}
	--find the highest y value
	for _,index in pairs(area_index) do
		if not spawn_table[index.x] then spawn_table[index.x] = {} end
		if not spawn_table[index.x][index.z] then
			spawn_table[index.x][index.z] = index.y
		elseif spawn_table[index.x][index.z] < index.y then
			spawn_table[index.x][index.z] = index.y
		end
	end
	
	for x,x_index in pairs(spawn_table) do
		for z,y in pairs(x_index) do
			local lightlevel = minetest.get_node_light(vector.new(x,y+1,z), 0.5)
			--print(lightlevel)
			if lightlevel >= 14 then
				--minetest.add_item(vector.new(x,y+1,z),ItemStack("main:glass"))
				--local node_list = minetest.find_nodes_in_area_under_air(vector.new(pos.x+x,pos.y-10,pos.z+z), vector.new(pos.x+x,pos.y+10,pos.z+z), all_nodes)
				--print(dump(minetest.registered_nodes))
				
				if math.random() > 0.995 then
					--make it so buildable to nodes get replaced
					local node = minetest.get_node(vector.new(x,y,z)).name
					local buildable = minetest.registered_nodes[node].buildable_to
					local walkable = minetest.registered_nodes[node].walkable
					local liquid = (minetest.registered_nodes[node].liquidtype ~= "none")
					
					if not liquid then
						if not buildable and minetest.get_node(vector.new(x,y+1,z)).name ~= "weather:snow" and walkable == true then
							minetest.set_node(vector.new(x,y+1,z),{name="weather:snow"})
						elseif buildable == true and minetest.get_node(vector.new(x,y,z)).name ~= "weather:snow" then
							minetest.set_node(vector.new(x,y,z),{name="weather:snow"})
						end
					end
				end
				
				local id = minetest.add_particlespawner({
					amount = 2,
					-- Number of particles spawned over the time period `time`.

					time = 0,
					-- Lifespan of spawner in seconds.
					-- If time is 0 spawner has infinite lifespan and spawns the `amount` on
					-- a per-second basis.

					minpos = vector.new(x-0.5,y,z-0.5),
					maxpos = vector.new(x+0.5,y+20,z+0.5),
					minvel = {x=-0.2, y=-0.2, z=-0.2},
					maxvel = {x=0.2, y=-0.5, z=0.2},
					minacc = {x=0, y=0, z=0},
					maxacc = {x=0, y=0, z=0},
					minexptime = 1,
					maxexptime = 1,
					minsize = 1,
					maxsize = 1,
					-- The particles' properties are random values between the min and max
					-- values.
					-- pos, velocity, acceleration, expirationtime, size

					collisiondetection = true,
					-- If true collide with `walkable` nodes and, depending on the
					-- `object_collision` field, objects too.

					collision_removal = true,
					-- If true particles are removed when they collide.
					-- Requires collisiondetection = true to have any effect.

					object_collision = false,
					-- If true particles collide with objects that are defined as
					-- `physical = true,` and `collide_with_objects = true,`.
					-- Requires collisiondetection = true to have any effect.

					--attached = ObjectRef,
					-- If defined, particle positions, velocities and accelerations are
					-- relative to this object's position and yaw

					--vertical = false,
					-- If true face player using y axis only

					texture = "snowflake_"..math.random(1,2)..".png",

					playername = player:get_player_name(),
					-- Optional, if specified spawns particles only on the player's client

					--animation = {Tile Animation definition},
					-- Optional, specifies how to animate the particles' texture

					--glow = 0
					-- Optional, specify particle self-luminescence in darkness.
					-- Values 0-14.
				})
				table.insert(particle_table,id)
			end
		end
	end
	meta:set_string("id table",minetest.serialize(particle_table))
end

--handle weather effects on players when joining
minetest.register_on_joinplayer(function(player)
	minetest.after(2, function(player)
		spawn_weather(player)
	end,player)
	player:set_sky({
	base_color="#808080",
	type="plain",
	clouds=false,
	
	day_sky = "#808080",
	dawn_horizon = "#808080",
	dawn_sky = "#808080",
	fog_sun_tint = "#808080",
	
	night_sky="#000000",
	night_horizon="#000000"
	})
	player:set_sun({visible=false})
	player:set_moon({visible=false})
	player:set_stars({visible=false})
end)

--handle weather effects during game loop
local weather_update_timer = 0
minetest.register_globalstep(function(dtime)
	weather_update_timer = weather_update_timer + dtime
	if weather_update_timer > 1 then
		weather_update_timer = 0
		for _,player in ipairs(minetest.get_connected_players()) do
			local meta = player:get_meta()
			local pos = vector.round(player:get_pos())
			
			if meta:contains("weather old pos") then
				local old_pos = minetest.string_to_pos(meta:get_string("weather old pos"))
				if not vector.equals(pos,old_pos) then
					if meta:contains("id table") then
						local particle_table = minetest.deserialize(meta:get_string("id table"))
						
						for id in pairs(particle_table) do
							minetest.delete_particlespawner(id, player:get_player_name())
						end
						meta:set_string("id table", nil)
					end
					--print("spawning weather")
					spawn_weather(player)
				end
			end
			
			meta:set_string("weather old pos", minetest.pos_to_string(pos))
		end
	end
end)

]]--

minetest.register_node("weather:snow", {
    description = "Snow",
    tiles = {"snow_block.png"},
    groups = {soft = 1, shovel = 1, hand = 1,pathable = 1,wool=1,dirt=1,falling_node=1},
    sounds = main.woolSound(),
    paramtype = "light",
	drawtype = "nodebox",
    drop = {
			max_items = 5,
			items= {
				{
					items = {"weather:snowball"},
				},
				{
					items = {"weather:snowball"},
				},
				{
					items = {"weather:snowball"},
				},
				{
					items = {"weather:snowball"},
				},
				{
					rarity = 5,
					items = {"weather:snowball"},
				},
			},
		},
    buildable_to = true,
    node_box = {
		type = "fixed",
		fixed = {
		{-8/16, -8/16, -8/16, 8/16, -6/16, 8/16},
		}
	},
})

local snowball_throw = function(player)
	local pos = player:get_pos()
	pos.y = pos.y + 1.625
	--let other players hear the noise too
	minetest.sound_play("woosh",{to_player=player:get_player_name(), pitch = math.random(80,100)/100})
	minetest.sound_play("woosh",{pos=pos, exclude_player = player:get_player_name(), pitch = math.random(80,100)/100})
	local snowball = minetest.add_entity(pos,"weather:snowball")
	if snowball then
		local vel = player:get_player_velocity()
		snowball:set_velocity(vector.add(vel,vector.multiply(player:get_look_dir(),20)))
		snowball:get_luaentity().thrower = player:get_player_name()
		return(true)
	end
	return(false)
end

minetest.register_craftitem("weather:snowball", {
	description = "Snowball",
	inventory_image = "snowball.png",
	--stack_max = 1,
	--range = 0,
	on_place = function(itemstack, placer, pointed_thing)
		local worked = snowball_throw(placer)
		if worked then
			itemstack:take_item()
		end
		return(itemstack)
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)
		local worked = snowball_throw(user)
		if worked then
			itemstack:take_item()
		end
		return(itemstack)
	end,
})


snowball = {}
snowball.initial_properties = {
	hp_max = 1,
	physical = true,
	collide_with_objects = false,
	collisionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
	visual = "sprite",
	visual_size = {x = 0.5, y = 0.5},
	textures = {
		"snowball.png"
	},
	is_visible = true,
	pointable = false,
}

snowball.snowball = true

snowball.on_activate = function(self)
	self.object:set_acceleration(vector.new(0,-9.81,0))
end

--make this as efficient as possible
--make it so you can hit one snowball with another
snowball.on_step = function(self, dtime)
	local vel = self.object:get_velocity()
	local hit = false
	local pos = self.object:get_pos()
	
	--hit object with the snowball
	for _,object in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
		if (object:is_player() and object:get_hp() > 0 and object:get_player_name() ~= self.thrower) or (object:get_luaentity() and object:get_luaentity().mob == true) then
			object:punch(self.object, 2, 
				{
				full_punch_interval=1.5,
				damage_groups = {fleshy=0},
			})
			hit = true
			break
		end
	end
	
	if (self.oldvel and ((vel.x == 0 and self.oldvel.x ~= 0) or (vel.y == 0 and self.oldvel.y ~= 0) or (vel.z == 0 and self.oldvel.z ~= 0))) or hit == true then
	
		minetest.sound_play("wool",{pos=pos, pitch = math.random(80,100)/100})
		minetest.add_particlespawner({
			amount = 20,
			-- Number of particles spawned over the time period `time`.

			time = 0.001,
			-- Lifespan of spawner in seconds.
			-- If time is 0 spawner has infinite lifespan and spawns the `amount` on
			-- a per-second basis.

			minpos = pos,
			maxpos = pos,
			minvel = {x=-2, y=3, z=-2},
			maxvel = {x=2, y=5, z=2},
			minacc = {x=0, y=-9.81, z=0},
			maxacc = {x=0, y=-9.81, z=0},
			minexptime = 1,
			maxexptime = 3,
			minsize = 1,
			maxsize = 1,
			-- The particles' properties are random values between the min and max
			-- values.
			-- pos, velocity, acceleration, expirationtime, size

			collisiondetection = true,

			collision_removal = true,

			object_collision = false,

			texture = "snowflake_"..math.random(1,2)..".png",

		})
		
		self.object:remove()
		
	end
	
	self.oldvel = vel
end
minetest.register_entity("weather:snowball", snowball)
