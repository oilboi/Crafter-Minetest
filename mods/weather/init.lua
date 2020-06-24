local minetest,vector,math = minetest,vector,math
local weather_channel = minetest.mod_channel_join("weather_type")
local weather_intake = minetest.mod_channel_join("weather_intake")
local weather_nodes_channel = minetest.mod_channel_join("weather_nodes")


weather_channel:send_all("")
weather_intake:send_all("")
weather_nodes_channel:send_all("")

local weather_max = 2
local mod_storage = minetest.get_mod_storage()

weather_type = mod_storage:get_int("weather_type")

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
		minetest.after(0,function()
		--print("sending player weather")
		--for some reason this variable assignment does not work outside the scope of this function
		local all_nodes_serialized = minetest.serialize(all_nodes)
		weather_nodes_channel:send_all(all_nodes_serialized)
		function_send_weather_type()
		update_player_sky()
		end)
	end
end)


minetest.register_on_joinplayer(function(player)
	minetest.after(3,function()
		local all_nodes_serialized = minetest.serialize(all_nodes)
		weather_nodes_channel:send_all(all_nodes_serialized)
		function_send_weather_type()
		update_player_sky()
	end)
end)

--spawn snow nodes
local cDoSnow_call_count_for_blanket_coverage  = 50 -- how many calls of do_snow() are required for blanket snow coverage
local cDoSnow_call_count_for_snowState_catchup = 20 -- how many calls of do_snow() (at most) before weather_snowState will catch up to the pattern on the ground (e.g. if player went somewhere else while it was snowing then came back)
local cSnowState_LFSR_taps, cSnowState_LFSR_length = 0x100D, 8191 -- Fizzlefade constants for the shortest maximum length LFSR that can cover an 80 x 80 area (i.e. has a length larger than 6400)
local cSnow_length_x = 80 -- (cSnow_length_x * cSnow_length_z) MUST be less than cSnowState_LFSR_length
local cSnow_length_y = 80
local cSnow_length_z = 80 -- (cSnow_length_x * cSnow_length_z) MUST be less than cSnowState_LFSR_length
local snow_area = vector.new(cSnow_length_x, cSnow_length_y, cSnow_length_z)
local snow_radius = vector.divide(snow_area, 2)
local pos
local min
local max
local subber = vector.subtract
local adder  = vector.add
local area_index
local under_air = minetest.find_nodes_in_area_under_air
local round_it = vector.round
local n_vec = vector.new
local lightlevel
local get_light = minetest.get_node_light
local g_node = minetest.get_node
local node_name
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
local temp_pos
local floor, ceil = math.floor, math.ceil
local weather_snowState
local snowState_iterations_per_call  = ceil(cSnowState_LFSR_length / cDoSnow_call_count_for_blanket_coverage)
local snowState_max_catchup_per_call = ceil(cSnowState_LFSR_length / cDoSnow_call_count_for_snowState_catchup)
local under_air_iterations
local catchup_steps
local lsfr_steps_count
local lsb
local location_bits
local relative_x
local relative_z
local under_air_count
local x, y, z

--this is debug
--local average = {}

function XOR( num1, num2 )
	-- This XOR function is excerpted from the Bitwise Operations Mod v1.2, by Leslie E. Krause
	-- which is provided under the MIT License (MIT)
	--
	-- The MIT License (MIT)
	--
	-- Copyright (c) 2020, Leslie Krause (leslie@searstower.org)
	--
	-- Permission is hereby granted, free of charge, to any person obtaining a copy of this
	-- software and associated documentation files (the "Software"), to deal in the Software
	-- without restriction, including without limitation the rights to use, copy, modify, merge,
	-- publish, distribute, sublicense, and/or sell copies of the Software, and to permit
	-- persons to whom the Software is furnished to do so, subject to the following conditions:
	--
	-- The above copyright notice and this permission notice shall be included in all copies or
	-- substantial portions of the Software.
	--
	-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
	-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
	-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
	-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
	-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
	-- DEALINGS IN THE SOFTWARE.
	--
	-- For more details:
	-- https://opensource.org/licenses/MIT

	local exp = 1
	local res = 0
	while num1 > 0 or num2 > 0 do
		local rem1 = num1 % 2
		local rem2 = num2 % 2
		if rem1 ~= rem2 then
			-- set each bit
			res = res + exp
		end
		num1 = ( num1 - rem1 ) / 2
		num2 = ( num2 - rem2 ) / 2
		exp = exp * 2
	end
	return res
end


local function do_snow()
	if weather_type == 1 then
		for _,player in ipairs(minetest.get_connected_players()) do
			--this is debug
			--local t0 = minetest.get_us_time()/1000000

			pos = round_it(player:get_pos())
			min = subber(pos, snow_radius)
			max = adder(pos, snow_radius)

			area_index = under_air(min, max, all_nodes)
			--local node_search_time = math.ceil((minetest.get_us_time()/1000000 - t0) * 1000)

			spawn_table = {}

			--the highest value is always indexed last in minetest.find_nodes_in_area_under_air,
			--so all that is needed is to iterate through it backwards and hook into the first
			--y value on the x and y and ignore the rest
			under_air_count = 0
			for key = #area_index,1,-1 do
				temp_pos = area_index[key]
				if not spawn_table[temp_pos.x] then spawn_table[temp_pos.x] = {} end
				if not spawn_table[temp_pos.x][temp_pos.z] then
					spawn_table[temp_pos.x][temp_pos.z] = temp_pos.y
					under_air_count = under_air_count + 1
				end
			end

			--save old method just in case useful or turns out it's faster after all
			--for _,index in pairs(area_index) do
			--	if not spawn_table[index.x] then spawn_table[index.x] = {} end
			--	if not spawn_table[index.x][index.z] then
			--		spawn_table[index.x][index.z] = index.y
			--	elseif spawn_table[index.x][index.z] < index.y then
			--		spawn_table[index.x][index.z] = index.y
			--	end
			--end

			bulk_list            = {}
			ice_list             = {}
			under_air_iterations = 0
			catchup_steps        = 0
			lsfr_steps_count     = 0
			repeat
				-- "fizzelfade" in the snow with a Linear Feedback Shift Register (LFSR)
				-- https://fabiensanglard.net/fizzlefade/index.php
				lsb = weather_snowState % 2 -- Get the output bit.
				weather_snowState = floor(weather_snowState / 2) -- Shift register
				if lsb == 1 then
					weather_snowState = XOR(weather_snowState, cSnowState_LFSR_taps)
				end
				lsfr_steps_count = lsfr_steps_count + 1

				location_bits = weather_snowState - 1 -- LFSR values start at 1, but we want snow to be able to fall on (0, 0)
				relative_x = location_bits % cSnow_length_x
				relative_z = floor(location_bits / cSnow_length_x)

				if relative_z < cSnow_length_z then
					x = (floor(min.x / cSnow_length_x) * cSnow_length_x) + relative_x -- align fizzelfade coords world-global
					if x < min.x then x = x + cSnow_length_x end -- ensure it falls in the same space as area_index
					local x_index = spawn_table[x]
					if x_index ~= nil then
						z = (floor(min.z / cSnow_length_z) * cSnow_length_z) + relative_z -- align fizzelfade coords world-global
						if z < min.z then z = z + cSnow_length_z end -- ensure it falls in the same space as area_index
						y = x_index[z]
						if y ~= nil then

							-- We hit a location that's in the spawn_table
							under_air_iterations = under_air_iterations + 1

							lightlevel = get_light(n_vec(x,y+1,z), 0.5)
							if lightlevel >= 14 then
								-- daylight is above or near this node, so snow can fall on it

								--make it so buildable to nodes get replaced
								node_name = g_node(n_vec(x,y,z)).name
								def = r_nodes[node_name]
								buildable = def.buildable_to
								walkable = def.walkable
								liquid = (def.liquidtype ~= "none")

								if not liquid then
									if buildable then
										if node_name ~= "weather:snow" then
											inserter(bulk_list, n_vec(x,y,z))
										else
											catchup_steps = catchup_steps + 1 -- we've already snowed on this spot
										end
									elseif walkable then
										if g_node(n_vec(x,y+1,z)).name ~= "weather:snow" then
											inserter(bulk_list, n_vec(x,y+1,z))
										else
											catchup_steps = catchup_steps + 1 -- we've already snowed on this spot
										end
									end
								elseif node_name == "main:water" then
									inserter(ice_list, n_vec(x,y,z))
								end
							end

						end
					end
				end
			until (lsfr_steps_count - catchup_steps) >= snowState_iterations_per_call or catchup_steps >= snowState_max_catchup_per_call

			if bulk_list then
				mass_set(bulk_list, {name="weather:snow"})
			end
			if ice_list then
				mass_set(ice_list, {name="main:ice"})
			end


			--this is debug
			--[[
			local chugent = math.ceil((minetest.get_us_time()/1000000 - t0) * 1000)
			print("---------------------------------")
			print("find_nodes_in_area_under_air() time: " .. node_search_time .. " ms")
			print("New Snow generation time:            " .. chugent .. " ms  [" .. (chugent - node_search_time) .. " ms]")

			inserter(average, chugent)
			local a = 0
			--don't cause memory leak
			if get_table_size(average) > 10 then
				table.remove(average,1)
			end
			for _,i in ipairs(average) do
				a = a + i
			end
			print(dump(average))
			a = a / get_table_size(average)
			print("average = "..a.."ms")
			minetest.chat_send_all("total nodes under air: " .. under_air_count .. ", LFSR iterations: " .. lsfr_steps_count .. ", under-air hits (nodes tested): " .. under_air_iterations .. "        Snow added: " .. (#bulk_list + #ice_list)  .. ", snow already there (catchup): " .. catchup_steps)
			--print("---------------------------------")
			--]]--
		end
	end

	minetest.after(3, function()
		do_snow()
	end)
end
minetest.register_on_mods_loaded(function()
	minetest.after(0,function()
		do_snow()
	end)
end)



--this sets random weather
local initial_run = true
local new_weather
local function randomize_weather()
	if not initial_run then
		new_weather = math.random(0,weather_max)
		if new_weather ~= weather_type or not weather_type then
			weather_type = new_weather
		else
			weather_type = 0
		end
		mod_storage:set_int("weather_type", weather_type)
	else
		initial_run = false
	end

	function_send_weather_type()
	update_player_sky()

	minetest.after((math.random(15,20)+math.random())*60, function()
		randomize_weather()
	end)
end

minetest.register_on_mods_loaded(function()
	minetest.after(0,function()
	if mod_storage:get_int("weather_initialized") == 0 then
		mod_storage:set_int("weather_initialized",1)
		weather_type = math.random(0,weather_max)
		mod_storage:set_int("weather_type", weather_type)
	end

	weather_snowState = math.max(mod_storage:get_int("weather_snowState"), 1)

	randomize_weather()
	end)
end)

minetest.register_on_shutdown(function()
	mod_storage:set_int("weather_type", weather_type)
	mod_storage:set_int("weather_snowState", weather_snowState)
end)

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

minetest.register_node("weather:snow_block", {
    description = "Snow",
    tiles = {"snow_block.png"},
    groups = {pathable = 1,snow = 1},
    sounds = main.woolSound(),
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
})

minetest.register_abm({
	label = "snow and ice melt",
	nodenames = {"weather:snow","main:ice"},
	neighbors = {"air"},
	interval = 3,
	chance = 10,
	catch_up = true,
	action = function(pos)
		if weather_type ~= 1 then
			minetest.remove_node(pos)
		end
	end,
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
		if (object:is_player() and object:get_hp() > 0 and object:get_player_name() ~= self.thrower) or (object:get_luaentity() and object:get_luaentity().mob == true and object ~= self.owner) then
			object:punch(self.object, 2,
				{
				full_punch_interval=1.5,
				damage_groups = {damage=0,fleshy=0},
			})
			hit = true
			break
		end
	end

	if (self.oldvel and ((vel.x == 0 and self.oldvel.x ~= 0) or (vel.y == 0 and self.oldvel.y ~= 0) or (vel.z == 0 and self.oldvel.z ~= 0))) or hit == true then
		--snowballs explode in the nether
		if pos.y <= -10033 and pos.y >= -20000 then
			self.object:remove()
			tnt(pos,4)
		else
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
	end

	self.oldvel = vel
end
minetest.register_entity("weather:snowball", snowball)
