local 
minetest,math,pairs,ipairs,table
=
minetest,math,pairs,ipairs,table

local pos
local name
local damage_nodes
local real_nodes
local a_min
local a_max
local _
local cancel_fall_damage = function(player)
	name = player:get_player_name()
	if player:get_hp() <= 0 then
		return
	end
	-- used for finding a damage node from the center of the player
	-- rudementary collision detection
	pos = player:get_pos()
	pos.y = pos.y
	a_min = vector.new(
		pos.x-0.25,
		pos.y-0.85,
		pos.z-0.25
	)
	a_max = vector.new(
		pos.x+0.25,
		pos.y+0.85,
		pos.z+0.25
	)
	_,saving_nodes = minetest.find_nodes_in_area( a_min,  a_max, {"group:disable_fall_damage"})
	real_nodes = {}
	for node_data,_ in pairs(saving_nodes) do
		if saving_nodes[node_data] > 0 then
			table.insert(real_nodes,node_data)
		end
	end
	-- find the highest damage node
	if table.getn(real_nodes) > 0 then
		return(true)
	end
	return(false)
end


local function calc_fall_damage(player,hp_change)
	if cancel_fall_damage(player) then
		return
	else
		local inv = player:get_inventory()
		local stack = inv:get_stack("armor_feet", 1)
		local name = stack:get_name()
		if name ~= "" then
			local absorption = 0

			absorption = minetest.get_item_group(name,"armor_level")*2
			--print("absorbtion:",absorption)
			local wear_level = ((9-minetest.get_item_group(name,"armor_level"))*8)*(5-minetest.get_item_group(name,"armor_type"))*math.abs(fall_damage)
			
			stack:add_wear(wear_level)
			
			inv:set_stack("armor_feet", 1, stack)
			
			local new_stack = inv:get_stack("armor_feet",1):get_name()

			if new_stack == "" then					
				minetest.sound_play("armor_break",{to_player=player:get_player_name(),gain=1,pitch=math.random(80,100)/100})
				recalculate_armor(player)
				set_armor_gui(player)
				--do particles too
			elseif minetest.get_item_group(new_stack,"boots") > 0 then 
				local pos = player:get_pos()
				minetest.add_particlespawner({
					amount = 30,
					time = 0.00001,
					minpos = {x=pos.x-0.5, y=pos.y+0.1, z=pos.z-0.5},
					maxpos = {x=pos.x+0.5, y=pos.y+0.1, z=pos.z+0.5},
					minvel = vector.new(-0.5,1,-0.5),
					maxvel = vector.new(0.5 ,2 ,0.5),
					minacc = {x=0, y=-9.81, z=1},
					maxacc = {x=0, y=-9.81, z=1},
					minexptime = 0.5,
					maxexptime = 1.5,
					minsize = 0,
					maxsize = 0,
					--attached = player,
					collisiondetection = true,
					collision_removal = true,
					vertical = false,
					node = {name= name.."particletexture"},
					--texture = "eat_particles_1.png"
				})
				minetest.sound_play("armor_fall_damage", {object=player, gain = 1.0, max_hear_distance = 60,pitch = math.random(80,100)/100})	
			end

			hp_change = hp_change + absorption

			if hp_change >= 0 then
				hp_change = 0
			else
				player:set_hp(player:get_hp()+hp_change,{reason="correction"})
				minetest.sound_play("hurt", {object=player, gain = 1.0, max_hear_distance = 60,pitch = math.random(80,100)/100})
			end
		else
			player:set_hp(player:get_hp()+hp_change,{reason="correction"})
			minetest.sound_play("hurt", {object=player, gain = 1.0, max_hear_distance = 60,pitch = math.random(80,100)/100})
		end
	end
end

local pool = {}
local name
local new_vel
local old_vel
local damage_calc
minetest.register_globalstep(function(dtime)
	for _,player in ipairs(minetest.get_connected_players()) do
		name = player:get_player_name()
		old_vel = pool[name]
		if old_vel then
			new_vel = player:get_player_velocity().y
			if old_vel < -15 and new_vel >= -0.5 then
				calc_fall_damage(player,math.ceil(old_vel+14))
			end
		end
		pool[name] = player:get_player_velocity().y
	end
end)

