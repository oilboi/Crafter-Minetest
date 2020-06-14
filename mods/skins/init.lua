local minetest,math,io,vector,table,pairs = minetest,math,io,vector,table,pairs

local http = minetest.request_http_api()
local id = "Lua Skins Updater"

-- binary downloads are required
if not core.features.httpfetch_binary_data then    
    minetest.log("error","Outdated Minetest Engine detected. Skins mod will not load. This crashes armor.")
    return(nil)
end

if not http then        
    minetest.log("error","---------------------------------------------------------------")
    minetest.log("error","HTTP access is required. Please add this to your minetest.conf:")
    minetest.log("error","secure.http_mods = skins")
    minetest.log("error","Skins will not work without this")
    minetest.log("error","---------------------------------------------------------------")
    return(nil)
end

-- only create classes if requirements are met

local skins             = {} -- skins class
skins.new_temp_path     = nil
skins.name              = nil
skins.player            = nil
skins.file              = nil
skins.temppath          = minetest.get_worldpath()
skins.get_player        = minetest.get_player_by_name
skins.open              = io.open
local player_skin_table = {}
skins_pointer           = {}

-- sets skin texture
skins.set_skin = function(player,skin)
    skins.name = player:get_player_name()
    player_skin_table[skins.name] = skin
end

-- gets skin texture
skins.get_skin = function(player)
    skins.name = player:get_player_name()
    if player_skin_table[skins.name] then
        return(player_skin_table[skins.name])
    else
        return("player.png")
    end
end


-- sets skin texture
skins_pointer.set_skin = function(player,skin)
    skins.name = player:get_player_name()
    player_skin_table[skins.name] = skin
end

-- gets skin texture
skins_pointer.get_skin = function(player)
    skins.name = player:get_player_name()
    if player_skin_table[skins.name] then
        return(player_skin_table[skins.name])
    else
        return("player.png")
    end
end

-- Fancy debug wrapper to download an URL
local function fetch_url(url, callback)
	http.fetch({
        url = url,
        timeout = 3,
    }, function(result)
        if result.succeeded then
            if result.code == 404 then
                return(nil)
            end
			if result.code ~= 200 then
                return(nil)
            end
            return callback(result.data)
        else
            return(nil)
        end
        return(nil)
	end)
end

-- gets github raw data of skin
fetch_function = function(name)
    fetch_url("https://raw.githubusercontent.com/"..name.."/crafter_skindex/master/skin.png", function(data)
        if data then
            skins.new_temp_path = skins.temppath .. "/skin_"..name..".png"

            skins.file = skins.open(skins.new_temp_path, "wb")
            skins.file:write(data)
            skins.file:close()

            -- set the player's skin
            skins.player = skins.get_player(name)
            
            assert(minetest.dynamic_add_media(skins.new_temp_path))
            
            skins.file = "skin_"..name..".png" -- reuse the data

            skins.player:set_properties({textures = {skins.file, "blank_skin.png"}})

            skins.set_skin(skins.player,skins.file)
            
            armor_class.recalculate_armor(skins.player) --redundancy
                
        end
    end)
end


local capes             = {} --capes class
capes.pos               = nil
capes.object            = nil
capes.old_pos           = nil
capes.current_animation = nil
capes.deg               = nil
capes.body_yaw          = nil
capes.cape_yaw          = nil
capes.cape_pitch        = nil
capes.goal              = nil

capes.pi                = math.pi
capes.half_pi           = capes.pi/2

capes.dir_to_yaw        = minetest.dir_to_yaw
capes.new_vector        = vector.new
capes.distance          = vector.distance
capes.direction         = vector.direction
capes.floor             = math.floor
capes.abs               = math.abs
capes.pairs             = pairs

-- simple degrees calculation
capes.degrees = function(yaw)
    return(yaw*180.0/capes.pi)
end

-- built in engine trigonometry
capes.pitch = function(pos,pos2)
    return(
        capes.floor(
            capes.degrees(
                capes.dir_to_yaw(
                    capes.new_vector(
                        capes.distance(
                            capes.new_vector(
                                pos.x,
                                0,
                                pos.z
                            ),
                            capes.new_vector(
                                pos2.x,
                                0,
                                pos2.z
                            )
                        ),
                        0,
                        pos.y - pos2.y
                    )
                )
                + capes.pi
            )
        )
    )
end

-- calculation to calculate the yaw of the old position
capes.cape_yaw_calculation = function(pos,pos2)
    return(
        capes.dir_to_yaw(
            capes.direction(
                capes.new_vector(
                    pos2.x,
                    0     ,
                    pos2.z
                ),
                capes.new_vector(
                    pos.x,
                    0    ,
                    pos.z
                )
            )
        )
    )
end

-- corrects degrees
capes.yaw_correction = function(yaw)
    if yaw < -180 then
        yaw = yaw + 360
    elseif yaw > 180 then
        yaw = yaw - 360
    end
    return(yaw)
end

-- returns if the cape can be "blown"
capes.move_cape = function(yaw,yaw2)
    capes.cape_yaw = capes.yaw_correction(capes.degrees(yaw-yaw2))
    return(capes.cape_yaw >= -90 and capes.cape_yaw <= 90)
end

-- applies movement to the cape
capes.cape_smoothing = function(object,current,cape_goal)
    if current ~= cape_goal then
        if capes.abs(current-cape_goal) <= 3 then --this stops jittering
            object:set_animation({x=cape_goal,y=cape_goal}, 0, 0, false)
        elseif current < cape_goal then
            object:set_animation({x=current+3,y=current+3}, 0, 0, false)
        elseif current > cape_goal then
            object:set_animation({x=current-3,y=current-3}, 0, 0, false)
        end
    end
end

local cape_object = {}
cape_object.initial_properties = {
	visual = "mesh",
	mesh = "cape.x",
	textures = {"cape_core.png"},
    pointable = false,
    collisionbox = {0, 0, 0, 0, 0, 0}
}

cape_object.texture_set = false

cape_object.on_activate = function(self)
    minetest.after(0,function()
         --don't waste any cpu
        if not self.owner or not self.owner:is_player() then
            self.object:remove()
            return
        end

        --set cape texture
        if self.texture_type and not self.texture_set then
            self.object:set_properties({textures={self.texture_type}})
            self.texture_type = nil
            self.texture_set  = nil
            return
        end
    end)
end

cape_object.on_step = function(self,dtime)
    capes.object            = self.object
    capes.pos               = capes.object:get_pos()
    capes.old_pos           = self.old_pos
    capes.current_animation = capes.object:get_animation() -- if fails assign other values to nil
    capes.current_animation = capes.current_animation.x

    if capes.old_pos then
        --do not allow cape to flutter if player is moving backwards
        capes.cape_yaw = capes.cape_yaw_calculation(capes.pos,capes.old_pos)
        capes.body_yaw = self.owner:get_look_horizontal()
        
        if capes.move_cape(capes.cape_yaw,capes.body_yaw) then
            capes.goal = capes.pitch(capes.pos,capes.old_pos)
        else
            capes.goal = 160
        end

        capes.cape_smoothing(capes.object,capes.current_animation,capes.goal)
    end

    self.old_pos = capes.pos
end

minetest.register_entity("skins:cape",cape_object)


local cape_handler         = {}
local cape_table           = {} -- holds all cape objects
cape_handler.object        = nil
cape_handler.lua_entity    = nil
cape_handler.name          = nil
cape_handler.temp_cape     = nil
cape_handler.pairs        = pairs


cape_handler.custom    = {
    sfan5      = true,
    appguru    = true,
    tacotexmex = true,
    oilboi     = true,
    wuzzy      = true,
}
cape_handler.core_devs = {
    celeron55  = true,
    nore       = true,
    nerzhul    = true,
    paramat    = true,
    sofar      = true,
    rubenwardy = true,
    smalljoker = true,
    larsh      = true,
    thetermos  = true,
    krock      = true,
}
cape_handler.patrons   = {
    tacotexmex = true,
    ufa        = true,
    monte48    = true,
}


-- simple check if has cape
cape_handler.get_texture = function(player)
    cape_handler.name = player:get_player_name()

    --cape handling
    cape_handler.name = string.lower(player:get_player_name())

    cape_handler.temp_cape = nil

    if cape_handler.custom[cape_handler.name] then
        cape_handler.temp_cape = "cape_"..cape_handler.name..".png"
    elseif cape_handler.core_devs[cape_handler.name] then
        cape_handler.cape_handler.temp_cape = "cape_core.png"
    elseif patrons[cape_handler.name] then
        cape_handler.cape_handler.temp_cape = "cape_patron.png"
    end
    return(cape_handler.temp_cape)
end

-- adds cape to player
cape_handler.add_cape = function(player)
    if cape_handler.get_texture(player) then
        cape_handler.object = minetest.add_entity(player:get_pos(),"skins:cape")
        cape_handler.lua_entity = cape_handler.object:get_luaentity()
        cape_handler.lua_entity.owner = player
        cape_handler.lua_entity.texture_type = cape_handler.temp_cape
        cape_handler.object:set_attach(player, "Cape_bone", vector.new(0,0,0), vector.new(0,0,0))
        cape_table[player:get_player_name()] = cape_handler.object
    end
end

-- looping check to see if cape deleted
cape_handler.readd_capes = function()
    for name,def in cape_handler.pairs(cape_table) do
        cape_handler.player = minetest.get_player_by_name(name)
        if cape_handler.player and cape_table[name] and not cape_table[name]:get_luaentity() then
            print("adding cape")
            cape_handler.add_cape(cape_handler.player)
        elseif not cape_handler.player then
            cape_table[name] = nil
        end
    end
    minetest.after(3,function()
        cape_handler.readd_capes()
    end)
end

minetest.register_on_mods_loaded(function()
    minetest.after(3,function()
        cape_handler.readd_capes()
    end)
end)


minetest.register_on_joinplayer(function(player)

    cape_handler.add_cape(player)

    minetest.after(0,function()
        fetch_function(player:get_player_name())
        armor_class.recalculate_armor(player)
    end)
end)
