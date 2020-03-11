--this is where mob spawning is defined

--spawn mob in a square doughnut shaped radius
local chance = 20
local tick = 0.2
local timer = 0
--inner and outer part of square donut radius
local inner = 24
local outer = 128

--for debug testing to isolate mobs
local spawn = true

minetest.register_globalstep(function(dtime)
	if spawn then
	timer = timer + dtime
	if timer >= tick and math.random(1,chance) == chance then
		--print("ticking")
		timer = 0
		--check through players
		for _,player in ipairs(minetest.get_connected_players()) do
			--don't spawn near dead players
			if player:get_hp() > 0 then
			
				--local mob_number = math.random(0,2)
				
				local int = {-1,1}
				local pos = vector.floor(vector.add(player:getpos(),0.5))
				
				local x,z
				
				--this is used to determine the axis buffer from the player
				local axis = math.random(0,1)
				
				--cast towards the direction
				if axis == 0 then --x
					x = pos.x + math.random(inner,outer)*int[math.random(1,2)]
					z = pos.z + math.random(-outer,outer)
				else --z
					z = pos.z + math.random(inner,outer)*int[math.random(1,2)]
					x = pos.x + math.random(-outer,outer)
				end
				
				
				local spawner = minetest.find_nodes_in_area_under_air(vector.new(x,pos.y-32,z), vector.new(x,pos.y+32,z), {"main:grass","main:sand","main:water"})
							
				--print(dump(spawner))
				if table.getn(spawner) > 0 then
					local mob_pos = spawner[1]
					mob_pos.y = mob_pos.y + 1
					--print("Spawning at: "..minetest.pos_to_string(mob_pos))
					minetest.add_entity(mob_pos,"mob:pig")
				end
			end
		end
	elseif timer > tick then
		timer = 0
	end
	end
end)
