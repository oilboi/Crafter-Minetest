local minetest,math,vector,ipairs,pairs,table = minetest,math,vector,ipairs,pairs,table

local food_class         = {}
local food_control_pool  = {} -- holds eating data
food_class.item          = nil
food_class.satiation     = nil
food_class.hunger        = nil
food_class.name          = nil
food_class.temp_particle = nil
food_class.temp_sound    = nil
food_class.eating_data   = nil
food_class.local_player  = nil
food_class.pos           = nil
food_class.control       = nil
food_class.speed         = nil
food_class.offset        = nil
food_class.copy          = table.copy
food_class.food_data     = {}
food_class.ipairs        = ipairs
food_class.pairs         = pairs
food_class.play          = minetest.sound_play
food_class.get_group     = minetest.get_item_group
food_class.get_connected = minetest.get_connected_players
food_class.add_vector    = vector.add
food_class.multiply      = vector.multiply
food_class.random        = math.random
food_class.add_ps        = minetest.add_particlespawner

food_class.particle_constant = {
    amount = 12,
    time = 0.01,
    minpos = {x=-0.1,y=-0.1,z=-0.1},
    maxpos = {x=0.1, y=0.3, z=0.1},
    minvel = {x=-0.5,y=0.2, z=-0.5},
    maxvel = {x=0.5,y=0.6,z=0.5},
    minacc = {x=0, y=-9.81, z=1},
    maxacc = {x=0, y=-9.81, z=1},
    minexptime = 0.5,
    maxexptime = 1.5,
    object_collision = false,
    collisiondetection = true,
    collision_removal = true,
    vertical = false,
}


-- creates volitile data for the game to use
food_class.create_data = function(player)
	food_class.name = player:get_player_name()
	if not food_control_pool[food_class.name] then
		food_control_pool[food_class.name] = {
			eating_step  = 0,
			eating_timer = 0,
		}
	end
end

-- sets data for the game to use
food_class.set_data = function(player,data)
	food_class.name = player:get_player_name()
	if food_control_pool[food_class.name] then
		for index,i_data in food_class.pairs(data) do
			if food_control_pool[food_class.name][index] ~= nil then
				food_control_pool[food_class.name][index] = i_data
			end
		end
	else
		movement_class.create_movement_variables(player)
	end
end

-- retrieves data for the game to use
food_class.get_data = function(player)
	food_class.name = player:get_player_name()
	if food_control_pool[food_class.name] then
		return({
			eating_step  = food_control_pool[food_class.name].eating_step ,
			eating_timer = food_control_pool[food_class.name].eating_timer,
		})
	end
end

-- removes movement data
food_class.terminate = function(player)
	food_class.name = player:get_player_name()
	if food_control_pool[food_class.name] then
		food_control_pool[food_class.name] = nil
	end
end

minetest.register_on_joinplayer(function(player)
	food_class.create_data(player)
end)
minetest.register_on_leaveplayer(function(player)
	food_class.terminate(player)
end)

food_class.manage_eating_effects = function(player,timer,sneaking,item)
    food_class.local_player = player
    food_class.pos = food_class.local_player:get_pos()
    food_class.speed = food_class.local_player:get_player_velocity()
    if sneaking then
        food_class.pos.y  = food_class.pos.y + 1.2
        food_class.offset = 0.6
    else
        food_class.pos.y = food_class.pos.y + 1.3
        food_class.offset = 0.3
    end

    food_class.pos = food_class.add_vector(food_class.pos, food_class.multiply(food_class.local_player:get_look_dir(),food_class.offset))

    food_class.temp_particle = food_class.copy(food_class.particle_constant)
    food_class.temp_particle.minpos = food_class.add_vector(food_class.pos,food_class.temp_particle.minpos)
    food_class.temp_particle.maxpos = food_class.add_vector(food_class.pos,food_class.temp_particle.maxpos)
    food_class.temp_particle.minvel = food_class.add_vector(food_class.speed,food_class.temp_particle.minvel)
    food_class.temp_particle.maxvel = food_class.add_vector(food_class.speed,food_class.temp_particle.maxvel)
    food_class.temp_particle.node   = {name=item.."node"}

    food_class.add_ps(food_class.temp_particle)
    if timer >= 0.2 then
        food_class.play("eat", {
            object = food_class.local_player,
            gain = 0.2                      ,
            pitch = food_class.random(60,85)/100}
        )
        return(0)
    end
    return(timer)
end

food_class.finish_eating = function(player,timer)
    if timer >= 1 then
        food_class.item = player:get_wielded_item()
        hunger_pointer.eat_food(player,food_class.item)
        food_class.play("eat_finish", {
            object = food_class.local_player,
            gain = 0.025                      ,
            pitch = food_class.random(60,85)/100}
        )
        return(0)
    end
    return(timer)
end

food_class.manage_eating = function(player,dtime)
    food_class.control = player:get_player_control()
    --eating
    if food_class.control.RMB then

        food_class.item = player:get_wielded_item():get_name()
        food_class.food_data.satiation = food_class.get_group( food_class.item, "satiation")
        food_class.food_data.hunger    = food_class.get_group( food_class.item, "hunger"   )
        
        if food_class.food_data.hunger > 0 or food_class.food_data.satiation > 0  then

            food_class.eating_data = food_class.get_data(player)
            
            food_class.eating_data.eating_step  = food_class.eating_data.eating_step  + dtime
            food_class.eating_data.eating_timer = food_class.eating_data.eating_timer + dtime

            food_class.eating_data.eating_timer = food_class.manage_eating_effects(player, food_class.eating_data.eating_timer, food_class.control.sneak,food_class.item)

            food_class.eating_data.eating_step = food_class.finish_eating(player,food_class.eating_data.eating_step)

            food_class.set_data(player,{
                eating_step  = food_class.eating_data.eating_step ,
                eating_timer = food_class.eating_data.eating_timer,
            })
        else
            food_class.set_data(player,{
                eating_step  = 0,
                eating_timer = 0,
            })
        end
    else
        food_class.set_data(player,{
            eating_step  = 0,
            eating_timer = 0,
        })
    end
end

minetest.register_globalstep(function(dtime)
	for _,player in food_class.ipairs(food_class.get_connected()) do
		food_class.manage_eating(player,dtime)
	end
end)