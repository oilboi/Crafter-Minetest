--this is where mobs are defined
local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer >= 0.5 then
		timer = 0
		--check through players
		for _,player in ipairs(minetest.get_connected_players()) do
			--don't spawn near dead players
			if player:get_hp() > 0 then
			
				local mob_number = math.random(0,2)
			
				local pos = vector.floor(vector.add(player:getpos(),0.5))
				
				local checkpos = minetest.find_nodes_in_area_under_air(vector.new(pos.x-50,pos.y-50,pos.z-50), vector.new(pos.x+50,pos.y+50,pos.z+50), {"main:grass","main:sand"})
				
				
				--[[
				local block = vector.floor(vector.divide(pos,16))
				block = vector.multiply(block, 16) --get the chunk actual base
				for x = 0,15 do
				for y = 0,15 do
				for z = 0,15 do
					
					if minetest.get_node(vector.new(block.x+x,block.y+y-1,block.z+z)).name ~= "air" and minetest.get_node(vector.new(block.x+x,block.y+y,block.z+z)).name == "air" then
					
						minetest.add_particle({
							pos = vector.new(block.x+x,block.y+y,block.z+z),
							velocity = {x=0, y=0, z=0},
							acceleration = {x=0, y=0, z=0},
							-- Spawn particle at pos with velocity and acceleration

							expirationtime = 0.5,
							-- Disappears after expirationtime seconds

							size = 2,
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

							texture = "dirt.png",

						})
					end
				end
				end
				end
				]]--
			end
		end
	end
end)
