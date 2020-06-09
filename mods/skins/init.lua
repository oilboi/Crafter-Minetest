local path = minetest.get_modpath(minetest.get_current_modname())

-- path for the temporary skins file
local temppath = minetest.get_worldpath() .. "/skins_temp.png"

local pngimage = dofile(path.."/png_lua/png.lua")

--run through all the skins on the skindex and index them all locally
--only try to index further than the point in the current list max

local http = minetest.request_http_api()
local id = "Lua Skins Updater"
-- Binary downloads are required
if not core.features.httpfetch_binary_data then
	print("outdated version of MINETEST detected!")
    return(nil)
end

if not http then
    for i = 1,5 do
        print("!WARNING!")
    end
    print("---------------------------------------------------------------")
    print("HTTP access is required. Please add this to your minetest.conf:")
    print("secure.http_mods = skins")
    print("!!Skins will not work without this!!")
    print("---------------------------------------------------------------")
    return(nil)
end

-- Fancy debug wrapper to download an URL
local function fetch_url(url, callback)
	http.fetch({
        url = url,
        timeout = 3,
    }, function(result)
        --print(dump(result))
        if result.succeeded then
            
			--if result.code ~= 200 then
				--core.log("warning", ("%s: STATUS=%i URL=%s"):format(
				--	_ID_, result.code, url))
			--end
			return callback(result.data)
		end
		core.log("warning", ("%s: Failed to download URL=%s"):format(
			id, url))
	end)
end

--https://gist.github.com/marceloCodget/3862929 rgb to hex

local function rgbToHex(rgb)

	local hexadecimal = ""

	for key, value in pairs(rgb) do
		local hex = ''

		while(value > 0)do
			local index = math.fmod(value, 16) + 1
			value = math.floor(value / 16)
			hex = string.sub('0123456789ABCDEF', index, index) .. hex			
		end

		if(string.len(hex) == 0)then
			hex = '00'

		elseif(string.len(hex) == 1)then
			hex = '0' .. hex
		end

		hexadecimal = hexadecimal .. hex
	end

	return hexadecimal
end

local xmax = 64
local ymax = 32
local function file_to_texture(image)
    local x = 1
    local y = 1
    --local base_texture = "[combine:"..xmax.."x"..ymax
    local base_texture = "[combine:" .. xmax .. "x" .. ymax
    --local base_texture2 = "[combine:"..xmax.."x"..ymax
    for _,line in pairs(image.pixels) do
        for _,data in pairs(line) do
            if x <= 32 or y > 16 then
                local hex = rgbToHex({data.R,data.G,data.B})
                --skip transparent pixels
                if data.A > 0 then 
                    --https://github.com/GreenXenith/skinmaker/blob/master/init.lua#L57 Thanks :D

                    base_texture = base_texture .. (":%s,%s=%s"):format(x - 1, y - 1, "(p.png\\^[colorize\\:#" .. hex .. ")")
                end
            --else
            --    print(dump(data))
            end
            x = x + 1
            if x > xmax then
                x = 1
                y = y + 1
            end
            if y > ymax then
                break
            end
        end
    end
    return(base_texture)
end

-- Function to fetch a range of pages
fetch_function = function(name)
    fetch_url("https://raw.githubusercontent.com/"..name.."/crafter_skindex/master/skin.png", function(data)
        if data then
            local f = io.open(temppath, "wb")
            f:write(data)
            f:close()

            local img = pngimage(temppath, nil, false, false)
            if img then
                local stored_texture = file_to_texture(img)

                --print("===============================================================")
                --print(stored_texture)
                if stored_texture then
                    --set the player's skin
                    local player = minetest.get_player_by_name(name)
                    player:set_properties({textures = {stored_texture, "blank_skin.png"}})
                    local meta = player:get_meta()
                    meta:set_string("skin",stored_texture)

                    recalculate_armor(player) --redundancy
                    
                    --[[
                    player:hud_add(
                        {
                            hud_elem_type = "image",  -- See HUD element types
                            -- Type of element, can be "image", "text", "statbar", or "inventory"
                    
                            position = {x=0.5, y=0.5},
                            -- Left corner position of element
                    
                            name = "<name>",
                    
                            scale = {x = 2, y = 2},
                    
                            text = stored_texture,
                    
                            text2 = "<text>",
                    
                            number = 2,
                    
                            item = 3,
                            -- Selected item in inventory. 0 for no item selected.
                    
                            direction = 0,
                            -- Direction: 0: left-right, 1: right-left, 2: top-bottom, 3: bottom-top
                    
                            alignment = {x=0, y=0},
                    
                            offset = {x=0, y=0},
                    
                            size = { x=100, y=100 },
                            -- Size of element in pixels
                    
                            z_index = 0,
                            -- Z index : lower z-index HUDs are displayed behind higher z-index HUDs
                        }
                    )
                    ]]--
                end
            end

        end
    end)
end

--local img = pngimage(minetest.get_modpath("skins").."/skin_temp/temp.png", nil, false, false)
--print(dump(img))



local cape = {}
cape.initial_properties = {
	visual = "mesh",
	mesh = "cape.x",
	textures = {"cape_core.png"},
    pointable = false,
    collisionbox = {0, 0, 0, 0, 0, 0}
}
cape.degrees = function(yaw)
    return(yaw*180.0/math.pi)
end
cape.texture_set = false
cape.on_step = function(self,dtime)
    --don't waste any cpu
    if not self.owner or not self.owner:is_player() then
        self.object:remove()
        return
    end
    --set cape texture
    if not self.texture_set and self.texture_type then
        self.object:set_properties({textures={self.texture_type}})
        self.texture_set = true
    end

    local pos = self.object:get_pos()
    local current_animation,_,_,_ = self.object:get_animation()
    current_animation = current_animation.x

    if self.old_pos then
        --do not allow cape to flutter if player is moving backwards
        local body_yaw = self.owner:get_look_horizontal()
        local cape_yaw = minetest.dir_to_yaw(vector.direction(self.old_pos,pos))
		cape_yaw = minetest.dir_to_yaw(minetest.yaw_to_dir(cape_yaw))
		cape_yaw = self.degrees(cape_yaw)-self.degrees(body_yaw)

		if cape_yaw < -180 then
			cape_yaw = cape_yaw + 360
		elseif cape_yaw > 180 then
			cape_yaw = cape_yaw - 360
        end
        if cape_yaw >= -90 and cape_yaw <= 90 then
            --use old position to calculate the "wind"
            local deg = self.degrees(minetest.dir_to_yaw(vector.new(vector.distance(vector.new(pos.x,0,pos.z),vector.new(self.old_pos.x,0,self.old_pos.z)),0,pos.y-self.old_pos.y))+(math.pi/2))*-1
            deg = deg + 90
            self.goal = math.floor(deg+0.5)
        else
            self.goal = 0
        end

        if vector.distance(pos,self.old_pos) == 0 then
            self.goal = 25
        end
    end
    --cape smoothing
    if self.goal and current_animation ~= self.goal then
        if math.abs(current_animation-self.goal) == 1 then --this stops jittering
            self.object:set_animation({x=self.goal,y=self.goal}, 0, 0, false)
        elseif current_animation < self.goal then
            self.object:set_animation({x=current_animation+2,y=current_animation+2}, 0, 0, false)
        elseif current_animation > self.goal then
            self.object:set_animation({x=current_animation-2,y=current_animation-2}, 0, 0, false)
        end
    end
    self.old_pos = pos
end
minetest.register_entity("skins:cape",cape)

--function for handling capes
local cape_table = {}

local add_cape = function(player,cape)
    local obj = minetest.add_entity(player:get_pos(),"skins:cape")
    obj:get_luaentity().owner = player
    obj:set_attach(player, "Cape_bone", vector.new(0,0.25,0.5), vector.new(-90,180,0))
    obj:get_luaentity().texture_type = cape
    local name = player:get_player_name()
	cape_table[name] = obj
end

local function readd_capes()
    for _,player in ipairs(minetest.get_connected_players()) do
        local meta = player:get_meta()
        local cape = meta:get_string("cape")
        if cape ~= "" then
            local name = player:get_player_name()
            if not cape_table[name] or (cape_table[name] and not cape_table[name]:get_luaentity()) then
                add_cape(player,cape)
                print("adding cape")
            end
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

local custom = {sfan5=true,appguru=true,tacotexmex=true,oilboi=true,wuzzy=true}

local core_devs = {celeron55=true,nore=true,nerzhul=true,paramat=true,sofar=true,rubenwardy=true,smalljoker=true,larsh=true,thetermos=true,krock=true}

local patrons = {tacotexmex=true,ufa=true,monte48=true}


minetest.register_on_joinplayer(function(player)
    local meta = player:get_meta()
    meta:set_string("skin","player.png")
    local name = string.lower(player:get_player_name())

    --cape handling
    local cape = false
    if custom[name] then
        cape = "cape_"..name..".png"
    elseif core_devs[name] then
        cape = "cape_core.png"
    elseif patrons[name] then
        cape = "cape_patron.png"
    end

    if cape then
        meta:set_string("cape",cape)
        add_cape(player,cape)
    else
        meta:set_string("cape","")
    end

    minetest.after(0,function()
        fetch_function(player:get_player_name())
    end)
end)
