local minetest,vector,math,table = minetest,vector,math,table

--this is where mob spawning is defined

--spawn mob in a square doughnut shaped radius
local timer = 6
--the amount of mobs that the game will try to spawn per player
local spawn_goal_per_player = 5
--the amount of mobs that the spawner will cap out at
local mob_limit = 100

--the height in which the game will search the x and z chosen (NUMBER up, NUMBER down)
local find_node_height = 32

--for debug testing to isolate mobs
local spawn = true

local spawn_table = {"pig","chicken","sheep"}
local snow_dark_spawn_table = {"snoider","sneeper",}
local snow_light_spawn_table = {"snowman"}
local dark_spawn_table = {"creeper","creeper","creeper","spider","spider","spider","big_slime","medium_slime","small_slime"}
local nether_spawn_table = {"nitro_creeper"}
local aether_spawn_table = {"phyg"}


local axis
--inner and outer part of square donut radius
local inner = 18
local outer = 50
local int = {-1,1}
local position_calculation = function(pos)				
	--this is used to determine the axis buffer from the player
	axis = math.random(0,1)

	--cast towards the direction
	if axis == 0 then --x
		pos.x = pos.x + math.random(inner,outer)*int[math.random(1,2)]
		pos.z = pos.z + math.random(-outer,outer)
	else --z
		pos.z = pos.z + math.random(inner,outer)*int[math.random(1,2)]
		pos.x = pos.x + math.random(-outer,outer)
	end
	return(pos)
end


local object_list
local entity
local counter
local get_mobs_in_radius = function(pos)
	counter = 0
	object_list = minetest.get_objects_inside_radius(pos, outer)
	for _,object in ipairs(object_list) do
		if not object:is_player() then
			entity = object:get_luaentity()

			if entity.is_mob then
				counter = counter + 1
			end
		end
	end
	return(counter)
end


local pos
local mobs
local spawner
local mob_spawning
local light_level
local function spawn_mobs(player)
	pos = player:get_pos()

	mobs = get_mobs_in_radius(pos)

	if mobs > spawn_goal_per_player then
		return
	end

	pos = position_calculation(pos)

	spawner = {}
	if pos.y >= 21000 then
		spawner = minetest.find_nodes_in_area_under_air(vector.new(pos.x,pos.y-find_node_height,pos.z), vector.new(pos.x,pos.y+find_node_height,pos.z), {"aether:grass"})
	elseif pos.y <= -10033 and pos.y >= -20112 then
		spawner = minetest.find_nodes_in_area_under_air(vector.new(pos.x,pos.y-find_node_height,pos.z), vector.new(pos.x,pos.y+find_node_height,pos.z), {"nether:netherrack"})
	else
		spawner = minetest.find_nodes_in_area_under_air(vector.new(pos.x,pos.y-find_node_height,pos.z), vector.new(pos.x,pos.y+find_node_height,pos.z), {"main:grass","main:sand","main:water"})
	end
	
	--print(dump(spawner))
	if table.getn(spawner) > 0 then
		local mob_pos = spawner[1]
		mob_pos.y = mob_pos.y + 1
		--aether spawning
		if mob_pos.y >= 21000 then
			mob_spawning = aether_spawn_table[math.random(1,table.getn(aether_spawn_table))]
			--print("Aether Spawning "..mob_spawning.." at: "..minetest.pos_to_string(mob_pos))
			minetest.add_entity(mob_pos,"mob:"..mob_spawning)
		elseif mob_pos.y <= -10033 and mob_pos.y >= -20112 then
			mob_spawning = nether_spawn_table[math.random(1,table.getn(nether_spawn_table))]
			--print("Nether Spawning "..mob_spawning.." at: "..minetest.pos_to_string(mob_pos))
			minetest.add_entity(mob_pos,"mob:"..mob_spawning)
		else
			light_level = minetest.get_node_light(spawner[1])

			if weather_type == 1 then
				if light_level < 10 then
					mob_spawning = snow_dark_spawn_table[math.random(1,table.getn(snow_dark_spawn_table))]
					--print("Snow Spawning "..mob_spawning.." at: "..minetest.pos_to_string(mob_pos))
					minetest.add_entity(mob_pos,"mob:"..mob_spawning)
				else
					local mob_spawning = snow_light_spawn_table[math.random(1,table.getn(snow_light_spawn_table))]
					--print("Snow Spawning "..mob_spawning.." at: "..minetest.pos_to_string(mob_pos))
					minetest.add_entity(mob_pos,"mob:"..mob_spawning)
				end
			else
				if light_level < 10 then
					mob_spawning = dark_spawn_table[math.random(1,table.getn(dark_spawn_table))]
					--print("Dark Spawning "..mob_spawning.." at: "..minetest.pos_to_string(mob_pos))
					minetest.add_entity(mob_pos,"mob:"..mob_spawning)
				else
					mob_spawning = spawn_table[math.random(1,table.getn(spawn_table))]
					--print("Light Spawning "..mob_spawning.." at: "..minetest.pos_to_string(mob_pos))
					minetest.add_entity(mob_pos,"mob:"..mob_spawning)
				end
			end
		end
	end
end

local function per_player_handling()
	if global_mob_amount < mob_limit then
		--check through players
		for _,player in ipairs(minetest.get_connected_players()) do
			spawn_mobs(player)
		end
	end

	minetest.after(10, function()
		per_player_handling()
	end)
end

if spawn then
	minetest.register_on_mods_loaded(function()
		minetest.after(0,function()
			per_player_handling()
		end)
	end)
end


