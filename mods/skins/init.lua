local
minetest,math,io,vector,table,pairs
=
minetest,math,io,vector,table,pairs

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
local pool = {}
local temppath = minetest.get_worldpath()

local name
function get_skin(player)
    name = player:get_player_name()
    return(pool[name] or "player.png")
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
local new_temp_path
local file
local player
local fetch_function = function(name)
    fetch_url("https://raw.githubusercontent.com/"..name.."/crafter_skindex/master/skin.png", function(data)
        if data then

            if not minetest.get_player_by_name(name) then
                return
            end
            new_temp_path = temppath .. DIR_DELIM .. "/skin_"..name..".png"

            file = io.open(new_temp_path, "wb")
            file:write(data)
            file:close()
            
            
            minetest.dynamic_add_media(new_temp_path)
            
            file = "skin_"..name..".png" -- reuse the data

            player = minetest.get_player_by_name(name)

            player:set_properties({textures = {file, "blank_skin.png"}})

            pool[name] = file
            
            recalculate_armor(player)
                
        end
    end)
end






local pi = math.pi

-- simple degrees calculation
local degrees = function(yaw)
    return(yaw*180.0/pi)
end

-- built in engine trigonometry
local pitch = function(pos,pos2)
    return(
        math.floor(
            degrees(
                minetest.dir_to_yaw(
                    vector.new(
                        vector.distance(
                            vector.new(
                                pos.x,
                                0,
                                pos.z
                            ),
                            vector.new(
                                pos2.x,
                                0,
                                pos2.z
                            )
                        ),
                        0,
                        pos.y - pos2.y
                    )
                )
                + pi
            )
        )
    )
end

-- calculation to calculate the yaw of the old position
local cape_yaw_calculation = function(pos,pos2)
    return(
        minetest.dir_to_yaw(
            vector.direction(
                vector.new(
                    pos2.x,
                    0     ,
                    pos2.z
                ),
                vector.new(
                    pos.x,
                    0    ,
                    pos.z
                )
            )
        )
    )
end

-- corrects degrees
yaw_correction = function(yaw)
    if yaw < -180 then
        yaw = yaw + 360
    elseif yaw > 180 then
        yaw = yaw - 360
    end
    return(yaw)
end

-- returns if the cape can be "blown"
local cape_yaw
local move_cape = function(yaw,yaw2)
    cape_yaw = yaw_correction(degrees(yaw-yaw2))
    return(cape_yaw >= -90 and cape_yaw <= 90)
end

-- applies movement to the cape
local cape_smoothing = function(object,current,cape_goal)
    if current ~= cape_goal then
        if math.abs(current-cape_goal) <= 3 then --this stops jittering
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

local object
local pos
local current_animation
local current_animation
local cape_yaw
local body_yaw
local goal
cape_object.on_step = function(self,dtime)
    object            = self.object
    pos               = object:get_pos()
    current_animation = object:get_animation() -- if fails assign other values to nil
    current_animation = current_animation.x
    goal              = nil
    if minetest.is_player(self.owner) and self.old_pos then
        --do not allow cape to flutter if player is moving backwards
        cape_yaw = cape_yaw_calculation(pos,self.old_pos)
        body_yaw = self.owner:get_look_horizontal()
        
        if move_cape(cape_yaw,body_yaw) then
            goal = pitch(pos,self.old_pos)
        else
            goal = 160
        end

        cape_smoothing(object,current_animation,goal)
    elseif not minetest.is_player(self.owner) then
        object:remove()
    end

    self.old_pos = pos
end

minetest.register_entity("skins:cape",cape_object)


local pool2 = {}


local custom    = {
    sfan5      = true,
    appguru    = true,
    tacotexmex = true,
    oilboi     = true,
    wuzzy      = true,
}
local core_devs = {
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
local patrons   = {
    tacotexmex = true,
    ufa        = true,
    monte48    = true,
}


-- simple check if has cape
local name
local temp_cape
local get_texture = function(player)
    if not player then
        return
    end

    name = string.lower(player:get_player_name())

    temp_cape = nil

    if custom[name] then
        temp_cape = "cape_"..name..".png"
    elseif core_devs[name] then
        temp_cape = "cape_core.png"
    elseif patrons[name] then
        temp_cape = "cape_patron.png"
    end
    return(temp_cape)
end

-- adds cape to player
local name
local temp_pool
local texture
local object
local lua_entity
local add_cape = function(player)
    if get_texture(player) then
        texture = get_texture(player)
        if texture then
            name = player:get_player_name()
            temp_pool = pool2[name]

            object = minetest.add_entity(player:get_pos(),"skins:cape")

            lua_entity = object:get_luaentity()

            lua_entity.owner = player
            lua_entity.texture_type = texture
            object:set_attach(player, "Cape_bone", vector.new(0,0,0), vector.new(0,0,0))
            pool2[name] = object
        end
    end
end

-- looping check to see if cape deleted
local player
local function readd_capes()
    for name,def in pairs(pool2) do
        player = minetest.get_player_by_name(name)
        if pool2[name] and not pool2[name]:get_luaentity() then
            add_cape(player)
        elseif not minetest.is_player(name) then
            pool2[name] = nil
        end
    end
    minetest.after(3,function()
        readd_capes()
    end)
end

minetest.register_on_mods_loaded(function()
    minetest.after(3,function()
        readd_capes()
    end)
end)


minetest.register_on_joinplayer(function(player)
    add_cape(player)

    minetest.after(0,function()
        fetch_function(player:get_player_name())
        recalculate_armor(player)
    end)
end)
