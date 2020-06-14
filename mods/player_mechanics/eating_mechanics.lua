local minetest,math,vector,ipairs,pairs,table = 
      minetest,math,vector,ipairs,pairs,table

local food_control_pool  = {}

local particle_constant = {
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
local name
local create_data = function(player)
    name = player:get_player_name()
    if not food_control_pool[name] then
		food_control_pool[name] = {
			eating_step  = 0,
			eating_timer = 0,
        }
    end
end


-- removes movement data
local name
local terminate terminate = function(player)
	name = player:get_player_name()
	if food_control_pool[name] then
		food_control_pool[name] = nil
	end
end

minetest.register_on_joinplayer(function(player)
	create_data(player)
end)
minetest.register_on_leaveplayer(function(player)
	terminate(player)
end)

-- manages player eating effects
local position
local velocity
local offset
local temp_particle
local manage_eating_effects = function(player,timer,sneaking,item)
    position    = player:get_pos()
    velocity    = player:get_player_velocity()

    if sneaking then
        position.y  = position.y + 1.2
        offset = 0.6
    else
        position.y = position.y + 1.3
        offset = 0.3
    end

    position = vector.add(position, vector.multiply(player:get_look_dir(),offset))

    temp_particle = table.copy(particle_constant)
    temp_particle.minpos = vector.add(position,temp_particle.minpos)
    temp_particle.maxpos = vector.add(position,temp_particle.maxpos)
    temp_particle.minvel = vector.add(velocity,temp_particle.minvel)
    temp_particle.maxvel = vector.add(velocity,temp_particle.maxvel)
    temp_particle.node   = {name=item.."node"}

    minetest.add_particlespawner(temp_particle)

    if timer >= 0.2 then
        minetest.sound_play("eat", {
            object = player,
            gain = 0.2                      ,
            pitch = math.random(60,85)/100}
        )
        return(0)
    end
    return(timer)
end


local item
finish_eating = function(player,timer)
    if timer >= 1 then
        item = player:get_wielded_item()

        hunger_pointer.eat_food(player,item)

        minetest.sound_play("eat_finish", {
            object = player,
            gain = 0.025                      ,
            pitch = math.random(60,85)/100}
        )
        return(0)
    end
    return(timer)
end


local name
local control
local item
local satiation
local hunger
local eating_step
local eating_timer
local manage_eating = function(player,dtime)
    control = player:get_player_control()
    name    = player:get_player_name()
    --eating
    if control.RMB then
        item      = player:get_wielded_item():get_name()

        satiation = minetest.get_item_group( item, "satiation")
        hunger    = minetest.get_item_group( item, "hunger"   )
        
        if hunger > 0 or satiation > 0  then

            eating_step  = food_control_pool[name][ "eating_step" ] + dtime
            eating_timer = food_control_pool[name][ "eating_timer"] + dtime

            eating_timer = manage_eating_effects(
                player,
                eating_timer,
                control.sneak,
                item
            )

            eating_step = finish_eating(
                player,
                eating_step
            )

            food_control_pool[name][ "eating_step" ] = eating_step
            food_control_pool[name][ "eating_timer"] = eating_timer
        else
            food_control_pool[name][ "eating_step" ] = 0
            food_control_pool[name][ "eating_timer"] = 0
        end
    else
        food_control_pool[name][ "eating_step" ] = 0
        food_control_pool[name][ "eating_timer"] = 0
    end
end

minetest.register_globalstep(function(dtime)
	for _,player in ipairs(minetest.get_connected_players()) do
		manage_eating(player,dtime)
	end
end)
