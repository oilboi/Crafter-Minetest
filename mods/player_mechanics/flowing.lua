local
minetest,vector,math,pairs
=
minetest,vector,math,pairs

local name
local pos
local node
local node_above
local goalx
local goalz
local currentvel
local level
local level2
local nodename
local acceleration
found = false
local function flow(player)
    name = player:get_player_name()
    pos = player:get_pos()
    pos.y = pos.y + player:get_properties().collisionbox[2]
    pos = vector.round(pos)
    node = minetest.get_node(pos).name
    node_above = minetest.get_node(vector.new(pos.x,pos.y+1,pos.z)).name
    goalx = 0
    goalz = 0
    found = false
    if node == "main:waterflow" then
        currentvel = player:get_player_velocity()
        level = minetest.get_node_level(pos)
        for x = -1,1 do
            for z = -1,1 do
                if found == false then
                    nodename = minetest.get_node(vector.new(pos.x+x,pos.y,pos.z+z)).name
                    level2 = minetest.get_node_level(vector.new(pos.x+x,pos.y,pos.z+z))
                    if level2 > level and nodename == "main:waterflow" or nodename == "main:water" then
                        goalx = -x
                        goalz = -z
                        --diagonal flow
                        if goalx ~= 0 and goalz ~= 0 then
                            found = true
                        end
                    end
                end
            end
        end
        --only add velocity if there is one
        --else this stops the player
        if goalx ~= 0 and goalz ~= 0 then
            acceleration = vector.new(goalx/1.5,0,goalz/1.5)
            player:add_player_velocity(acceleration)
        elseif goalx ~= 0 or goalz ~= 0 then
            acceleration = vector.new(goalx,0,goalz)
            player:add_player_velocity(acceleration)
        end
    end
end

local legs
local flowing
minetest.register_globalstep(function()
    for _,player in ipairs(minetest.get_connected_players()) do
        legs = minetest.get_item_group(get_player_legs_env(player),"water") > 0
        if legs then
            flow(player)
        end
    end
end)