local weather_channel = minetest.mod_channel_join("weather_type")
local weather_intake = minetest.mod_channel_join("weather_intake")
local weather_nodes_channel = minetest.mod_channel_join("weather_nodes")


local weather_max = 2
weather_type = math.random(0,weather_max)
local weather_timer = 0

local path = minetest.get_modpath(minetest.get_current_modname())
dofile(path.."/commands.lua")


--this updates players skys since it cannot be done clientside
update_player_sky = function()
	for _,player in ipairs(minetest.get_connected_players()) do
		if weather_type ~= 0 then
			player:set_sky({
				base_color="#808080",
				type="plain",
				clouds=false,
				
				day_sky = "#808080",
				dawn_horizon = "#808080",
				dawn_sky = "#808080",
				fog_sun_tint = "#808080",
				
				night_sky="#808080",
				night_horizon="#808080"
			})
			player:set_sun({visible=false,sunrise_visible=false})
			player:set_moon({visible=false})
			player:set_stars({visible=false})
		else
			player:set_sky({
				base_color="#8cbafa",
				type="regular",
				clouds=true,
				
				day_sky = "#8cbafa",
				
				dawn_horizon = "#bac1f0",
				dawn_sky = "#b4bafa",
				
				night_sky="#006aff",
				night_horizon="#4090ff"
			})
			
			player:set_sun({visible=true,sunrise_visible=true})
			player:set_moon({visible=true})
			player:set_stars({visible=true})
		end
	end
end

--this tells the client mod to update the weather type
function_send_weather_type = function()
	weather_channel:send_all(tostring(weather_type))
end

--index all mods
local all_nodes = {}
minetest.register_on_mods_loaded(function()
	for name in pairs(minetest.registered_nodes) do
		if name ~= "air" and name ~= "ignore" then
			table.insert(all_nodes,name)
		end
	end	
end)

--this sends the client all nodes that weather can be on top of
--(everything)

--have the client send the server the ready signal
minetest.register_on_modchannel_message(function(channel_name, sender, message)
	if channel_name == "weather_intake" then
		print("sending player weather")
		--for some reason this variable assignment does not work outside the scope of this function
		local all_nodes_serialized = minetest.serialize(all_nodes)
		weather_nodes_channel:send_all(all_nodes_serialized)
		function_send_weather_type()
		update_player_sky()
	end
end)


--spawn snow nodes
local pos
local area = vector.new(80,40,80)
local min
local max
local subber = vector.subtract
local adder  = vector.add
local area_index
local under_air = minetest.find_nodes_in_area_under_air
local area
local round_it = vector.round
local randomize_number = math.random
local n_vec = vector.new
local lightlevel
local get_light = minetest.get_node_light
local g_node = minetest.get_node
local node
local def
local buildable
local walkable
local liquid
local r_nodes = minetest.registered_nodes
local bulk_list
local ice_list
local spawn_table
local mass_set = minetest.bulk_set_node
local inserter = table.insert
local function do_snow()
	if weather_type == 1 then
		for _,player in ipairs(minetest.get_connected_players()) do
			local t0 = os.clock()
			--print("running")
			pos = round_it(player:get_pos())
			
			area = n_vec(80,40,80)
			min = subber(pos, area)
			max = adder(pos, area)
			
			area_index = under_air(min, max, all_nodes)
			
			spawn_table = {}
			for _,index in pairs(area_index) do
				if not spawn_table[index.x] then spawn_table[index.x] = {} end
				if not spawn_table[index.x][index.z] then
					spawn_table[index.x][index.z] = index.y
				elseif spawn_table[index.x][index.z] < index.y then
					spawn_table[index.x][index.z] = index.y
				end
			end
		
			
			--find the highest y value
			bulk_list = {}
			ice_list = {}
			for x,x_index in pairs(spawn_table) do
				for z,y in pairs(x_index) do
					if randomize_number(1,1000) >= 995 then
						lightlevel = get_light(n_vec(x,y+1,z), 0.5)
						if lightlevel >= 14 then
							--make it so buildable to nodes get replaced
							node = g_node(n_vec(x,y,z)).name
							def = r_nodes[node]
							buildable = def.buildable_to
							walkable = def.walkable
							liquid = (def.liquidtype ~= "none")
							
							if not liquid then
								if not buildable and g_node(n_vec(x,y+1,z)).name ~= "weather:snow" and walkable == true then
									inserter(bulk_list, n_vec(x,y+1,z))
								elseif buildable == true and node ~= "weather:snow" then
									inserter(bulk_list, n_vec(x,y,z))
								end
							elseif g_node(n_vec(x,y,z)).name == "main:water" then
								inserter(ice_list, n_vec(x,y,z))
							end
						end
					end
				end
			end
			if bulk_list then
				mass_set(bulk_list, {name="weather:snow"})
			end
			if ice_list then
				mass_set(ice_list, {name="main:ice"})
			end
			
			local chugent = math.ceil((os.clock() - t0) * 1000)
			print ("[lvm_example] Mapchunk generation time " .. chugent .. " ms")
		end
	end
	
	minetest.after(2, function()
		do_snow()
	end)
end

do_snow()



--this sets random weather
local weather_timer_goal = (math.random(5,7)+math.random())*60
--minetest.register_globalstep(function(dtime)
local function randomize_weather()
	weather_type = math.random(0,weather_max)
	function_send_weather_type()
	update_player_sky()
	minetest.after((math.random(5,7)+math.random())*60, function()
		randomize_weather()
	end)
end
randomize_weather()

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

minetest.register_node("weather:snow", {
    description = "Snow",
    tiles = {"snow_block.png"},
    groups = {pathable = 1,snow = 1, falling_node=1},
    sounds = main.woolSound(),
    paramtype = "light",
	drawtype = "nodebox",
	walkable = false,
	floodable = true,
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
				damage_groups = {damage=0},
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
