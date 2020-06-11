local minetest = minetest

local player_huds = {} -- the list of players hud lists (3d array)
hud_manager = {}       -- hud manager class

-- terminate the player's list on leave
minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    player_huds[name] = nil
end)

-- create instance of new hud
hud_manager.add_hud = function(player,hud_name,def)
    local name = player:get_player_name()
    local local_hud = player:hud_add({
		hud_elem_type = def.hud_elem_type,
		position      = def.position,
		text          = def.text,
		number        = def.number,
		direction     = def.direction,
		size          = def.size,
		offset        = def.offset,
    })
    -- create new 3d array here
    -- depends.txt is not needed
    -- with it here
    if not player_huds[name] then
        player_huds[name] = {}
    end

    player_huds[name][hud_name] = local_hud
end

-- delete instance of hud
hud_manager.remove_hud = function(player,hud_name)
    local name = player:get_player_name()
    if player_huds[name] and player_huds[name][hud_name] then
        player:hud_remove(player_huds[name][hud_name])
        player_huds[name][hud_name] = nil
    end
end

-- change element of hud
hud_manager.change_hud = function(data)
    local name = data.player:get_player_name()
    if player_huds[name] and player_huds[name][data.hud_name] then
        data.player:hud_change(player_huds[name][data.hud_name], data.element, data.data)
    end
end

-- gets if hud exists
hud_manager.hud_exists = function(player,hud_name)
    local name = player:get_player_name()
    if player_huds[name] and player_huds[name][hud_name] then
        return(true)
    else
        return(false)
    end
end