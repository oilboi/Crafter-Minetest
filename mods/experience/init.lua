minetest.hud_replace_builtin("health",{
    hud_elem_type = "statbar",
    position = {x = 0.5, y = 1},
    text = "heart.png",
    number = core.PLAYER_MAX_HP_DEFAULT,
    direction = 0,
    size = {x = 24, y = 24},
    offset = {x = (-10 * 24) - 25, y = -(48 + 24 + 38)},
})

local experience_bar_max = 36
minetest.register_on_joinplayer(function(player)
    local meta = player:get_meta()
    meta:set_float("experience_collection_buffer",0)
        player:hud_add({
        hud_elem_type = "statbar",
        position = {x = 0.5, y = 1},
        text = "heart_bg.png",
        number = core.PLAYER_MAX_HP_DEFAULT,
        direction = 0,
        size = {x = 24, y = 24},
        offset = {x = (-10 * 24) - 25, y = -(48 + 24 + 38)},
    })
    player:hud_add({
        hud_elem_type = "statbar",  -- See HUD element types
        -- Type of element, can be "image", "text", "statbar", or "inventory"

        position = {x=0.5, y=1},
        -- Left corner position of element

        name = "experience",

        --scale = {x = 2, y = 2},

        text = "experience_bar_background.png",

        number = experience_bar_max,

        --item = 3,
        -- Selected item in inventory. 0 for no item selected.

        direction = 0,
        -- Direction: 0: left-right, 1: right-left, 2: top-bottom, 3: bottom-top

        offset = {x = (-8 * 28) - 29, y = -(48 + 24 + 16)},

        size = { x=28, y=28 },
        -- Size of element in pixels

        z_index = 0,
        -- Z index : lower z-index HUDs are displayed behind higher z-index HUDs
    })
    local hud_id = player:hud_add({
        hud_elem_type = "statbar",  -- See HUD element types
        -- Type of element, can be "image", "text", "statbar", or "inventory"

        position = {x=0.5, y=1},
        -- Left corner position of element

        name = "experience",

        --scale = {x = 2, y = 2},

        text = "experience_bar.png",

        number = meta:get_int("experience_bar_count"),

        --item = 3,
        -- Selected item in inventory. 0 for no item selected.

        direction = 0,
        -- Direction: 0: left-right, 1: right-left, 2: top-bottom, 3: bottom-top

        offset = {x = (-8 * 28) - 29, y = -(48 + 24 + 16)},

        size = { x=28, y=28 },
        -- Size of element in pixels

        z_index = 0,
        -- Z index : lower z-index HUDs are displayed behind higher z-index HUDs
    })
    
    local meta = player:get_meta()
    local level = meta:get_int("experience_level")                                
    local hud_bg_id = player:hud_add({
        hud_elem_type = "text",  -- See HUD element types
        -- Type of element, can be "image", "text", "statbar", or "inventory"

        position = {x=0.5, y=1},
        -- Left corner position of element

        name = "levelbg",

        --scale = {x = 2, y = 2},

        text = tostring(level),

        number = 0x000000,--0xFFFFFF,

        --item = 3,
        -- Selected item in inventory. 0 for no item selected.

        --direction = 0,
        -- Direction: 0: left-right, 1: right-left, 2: top-bottom, 3: bottom-top

        offset = {x = 0, y = -(48 + 24 + 24)},

        size = { x=28, y=28 },
        -- Size of element in pixels

        z_index = 0,
        -- Z index : lower z-index HUDs are displayed behind higher z-index HUDs
    })                            
    local hud_fg_id = player:hud_add({
        hud_elem_type = "text",  -- See HUD element types
        -- Type of element, can be "image", "text", "statbar", or "inventory"

        position = {x=0.5, y=1},
        -- Left corner position of element

        name = "levelfg",

        --scale = {x = 2, y = 2},

        text = tostring(level),

        number = 0xFFFFFF,

        --item = 3,
        -- Selected item in inventory. 0 for no item selected.

        --direction = 0,
        -- Direction: 0: left-right, 1: right-left, 2: top-bottom, 3: bottom-top

        offset = {x = -1, y = -(48 + 24 + 25)},

        size = { x=28, y=28 },
        -- Size of element in pixels

        z_index = 0,
        -- Z index : lower z-index HUDs are displayed behind higher z-index HUDs
    }) 
    meta:set_int("experience_bar", hud_id)
    meta:set_int("experience_level_fg", hud_fg_id)                                
    meta:set_int("experience_level_bg", hud_bg_id)                                                            
end)


function level_up_experience(player)
    local meta = player:get_meta()
    local level = meta:get_int("experience_level")
    level = level + 1
    meta:set_int("experience_level",level)
    
    local hud_fg_id = meta:get_int("experience_level_fg")
    local hud_bg_id = meta:get_int("experience_level_bg")
    
    player:hud_change(hud_bg_id, "text", tostring(level))
    player:hud_change(hud_fg_id, "text", tostring(level))
end

function add_experience(player,experience)
    local meta = player:get_meta()
    local hud_id = meta:get_int("experience_bar")
    local hud = player:hud_get(hud_id)
    local bar_count = hud.number
    bar_count = bar_count + experience
    if bar_count > experience_bar_max then
        minetest.sound_play("level_up",{gain=0.2,to_player = player:get_player_name()})
        bar_count = bar_count - experience_bar_max
        level_up_experience(player)
    else
        minetest.sound_play("experience",{gain=0.1,to_player = player:get_player_name(),pitch=math.random(75,99)/100})
    end
    meta:set_int("experience_bar_count",bar_count)
    player:hud_change(hud_id, number, bar_count)
end

--[[
local function test_experience()
    for _, player in pairs(minetest.get_connected_players()) do
        add_experience(player,math.random(1,3)*2)
    end
       
    minetest.after(0.3, function()
        test_experience()
    end)
end
test_experience()                  
]]--

--reset player level
minetest.register_on_dieplayer(function(player)
    local meta = player:get_meta()
    local amount_of_experience = (meta:get_int("experience_bar_count")/2) + (meta:get_int("experience_level") * 18)
    --bar
    meta:set_int("experience_bar_count",0)
    local hud_id = meta:get_int("experience_bar")
    player:hud_change(hud_id, number, 0)
                              
    --level number
    local level = 0
    meta:set_int("experience_level",level)
    
    local hud_fg_id = meta:get_int("experience_level_fg")
    local hud_bg_id = meta:get_int("experience_level_bg")
    
    player:hud_change(hud_bg_id, "text", tostring(level))
    player:hud_change(hud_fg_id, "text", tostring(level))
                              
    minetest.throw_experience(player:get_pos(), amount_of_experience)
                              
end)


local time_to_live = tonumber(minetest.settings:get("item_entity_ttl")) or 300
local gravity = tonumber(minetest.settings:get("movement_gravity")) or 9.81


minetest.register_entity("experience:orb", {
	initial_properties = {
		hp_max = 1,
		physical = true,
		collide_with_objects = false,
		collisionbox = {-0.2, -0.2, -0.2, 0.2, 0.2, 0.2},
		visual = "sprite",
		visual_size = {x = 0.4, y = 0.4},
		textures = {"experience_orb.png"},
		spritediv = {x = 1, y = 1},
		initial_sprite_basepos = {x = 0, y = 0},
		is_visible = true,
		pointable = false,
	},

	moving_state = true,
	slippery_state = false,
	physical_state = true,
	-- Item expiry
	age = 0,
	-- Pushing item out of solid nodes
	force_out = nil,
	force_out_start = nil,
	--Collection Variables
	collection_timer = 2,
	collection_timer_goal = collection.collection_time,
	collection_height = 0.8,
	collectable = false,
	try_timer = 0,
	collected = false,
	delete_timer = 0,
	radius = collection.magnet_radius,
	time_to_live = time_to_live,

	get_staticdata = function(self)
		return minetest.serialize({
			age = self.age,
			collection_timer = self.collection_timer,
			collectable = self.collectable,
			try_timer = self.try_timer,
			collected = self.collected,
			delete_timer = self.delete_timer,
			collector = self.collector,
		})
	end,

	on_activate = function(self, staticdata, dtime_s)
		if string.sub(staticdata, 1, string.len("return")) == "return" then
			local data = minetest.deserialize(staticdata)
			if data and type(data) == "table" then
				self.age = (data.age or 0) + dtime_s
				self.collection_timer = data.collection_timer
				self.collectable = data.collectable
				self.try_timer = data.try_timer
				self.collected = data.collected
				self.delete_timer = data.delete_timer
				self.collector = data.collector
				--print("restored timer: "..self.collection_timer)
			end
		else

			local x=math.random(-2,2)*math.random()
			local y=math.random(2,5)
			local z=math.random(-2,2)*math.random()
			self.object:setvelocity(vector.new(x,y,z))
		     -- print(self.collection_timer)
		end
		self.object:set_armor_groups({immortal = 1})
		self.object:set_velocity({x = 0, y = 2, z = 0})
		self.object:set_acceleration({x = 0, y = -gravity, z = 0})
        local size = math.random(20,36)/100
        self.object:set_properties({
			visual_size = {x = size, y = size},
			glow = 14,
		})
	end,

	enable_physics = function(self)
		if not self.physical_state then
			self.physical_state = true
			self.object:set_properties({physical = true})
			self.object:set_velocity({x=0, y=0, z=0})
			self.object:set_acceleration({x=0, y=-gravity, z=0})
		end
	end,

	disable_physics = function(self)
		if self.physical_state then
			self.physical_state = false
			self.object:set_properties({physical = false})
			self.object:set_velocity({x=0, y=0, z=0})
			self.object:set_acceleration({x=0, y=0, z=0})
		end
	end,
	on_step = function(self, dtime)
		--if item set to be collected then only execute go to player
		if self.collected == true then
			if not self.collector then
				self.collected = false
				return
			end
			local collector = minetest.get_player_by_name(self.collector)
			if collector then
				self.object:setacceleration(vector.new(0,0,0))
				self.disable_physics(self)
				--get the variables
				local pos = self.object:getpos()
				local pos2 = collector:getpos()
				
                local player_velocity = collector:get_player_velocity()
                                            
				pos2.y = pos2.y + self.collection_height
								
				local direction = vector.direction(pos,pos2)
				local distance = vector.distance(pos2,pos)
                local multiplier = distance
                if multiplier < 1 then
                    multiplier = 1
                end
				local goal = vector.multiply(direction,multiplier)
                local currentvel = self.object:get_velocity()
                local acceleration
				if distance > 1 then
                    local multiplier = (self.radius*5) - distance
                    local velocity = vector.multiply(direction,multiplier)
                    local goal = velocity--vector.add(player_velocity,velocity)
                    acceleration = vector.new(goal.x-currentvel.x,goal.y-currentvel.y,goal.z-currentvel.z)
                else
                    acceleration = vector.new(goal.x,goal.y,goal.z)
                end
				--acceleration = vector.multiply(acceleration, )
                                            
                
				
				self.object:add_velocity(acceleration)
				
                                            
                                            
                    
                local meta = collector:get_meta()
                local experience_collection_buffer = meta:get_float("experience_collection_buffer")
				if distance < 0.2 and experience_collection_buffer == 0 then
                    meta:set_float("experience_collection_buffer",0.04)
                    add_experience(collector,2)
					self.object:remove()
				end
				
				
				--self.delete_timer = self.delete_timer + dtime
				--this is where the item gets removed from world
				--if self.delete_timer > 1 then
				--	self.object:remove()
				--end
				return
			else
				print(self.collector.." does not exist")
				self.object:remove()
			end
		end
		
		--allow entity to be collected after timer
		if self.collectable == false and self.collection_timer >= self.collection_timer_goal then
			self.collectable = true
		elseif self.collectable == false then
			self.collection_timer = self.collection_timer + dtime
		end
				
		self.age = self.age + dtime
		if self.time_to_live > 0 and self.age > self.time_to_live then
			self.object:remove()
			return
		end

		local pos = self.object:get_pos()
		local node = minetest.get_node_or_nil({
			x = pos.x,
			y = pos.y + self.object:get_properties().collisionbox[2] - 0.05,
			z = pos.z
		})
		

		-- Remove nodes in 'ignore'
		if node and node.name == "ignore" then
			self.object:remove()
			return
		end

		local is_stuck = false
		local snode = minetest.get_node_or_nil(pos)
		if snode then
			local sdef = minetest.registered_nodes[snode.name] or {}
			is_stuck = (sdef.walkable == nil or sdef.walkable == true)
				and (sdef.collision_box == nil or sdef.collision_box.type == "regular")
				and (sdef.node_box == nil or sdef.node_box.type == "regular")
		end

		-- Push item out when stuck inside solid node
		if is_stuck then
			local shootdir
			local order = {
				{x=1, y=0, z=0}, {x=-1, y=0, z= 0},
				{x=0, y=0, z=1}, {x= 0, y=0, z=-1},
			}

			-- Check which one of the 4 sides is free
			for o = 1, #order do
				local cnode = minetest.get_node(vector.add(pos, order[o])).name
				local cdef = minetest.registered_nodes[cnode] or {}
				if cnode ~= "ignore" and cdef.walkable == false then
					shootdir = order[o]
					break
				end
			end
			-- If none of the 4 sides is free, check upwards
			if not shootdir then
				shootdir = {x=0, y=1, z=0}
				local cnode = minetest.get_node(vector.add(pos, shootdir)).name
				if cnode == "ignore" then
					shootdir = nil -- Do not push into ignore
				end
			end

			if shootdir then
				-- Set new item moving speed accordingly
				local newv = vector.multiply(shootdir, 3)
				self:disable_physics()
				self.object:set_velocity(newv)

				self.force_out = newv
				self.force_out_start = vector.round(pos)
				return
			end
		elseif self.force_out then
			-- This code runs after the entity got a push from the above code.
			-- It makes sure the entity is entirely outside the solid node
			local c = self.object:get_properties().collisionbox
			local s = self.force_out_start
			local f = self.force_out
			local ok = (f.x > 0 and pos.x + c[1] > s.x + 0.5) or
				(f.y > 0 and pos.y + c[2] > s.y + 0.5) or
				(f.z > 0 and pos.z + c[3] > s.z + 0.5) or
				(f.x < 0 and pos.x + c[4] < s.x - 0.5) or
				(f.z < 0 and pos.z + c[6] < s.z - 0.5)
			if ok then
				-- Item was successfully forced out
				self.force_out = nil
				self:enable_physics()
			end
		end

		if not self.physical_state then
			return -- Don't do anything
		end

		-- Slide on slippery nodes
		local vel = self.object:get_velocity()
		local def = node and minetest.registered_nodes[node.name]
		local is_moving = (def and not def.walkable) or
			vel.x ~= 0 or vel.y ~= 0 or vel.z ~= 0
		local is_slippery = false

		if def and def.walkable then
			local slippery = minetest.get_item_group(node.name, "slippery")
			is_slippery = slippery ~= 0
			if is_slippery and (math.abs(vel.x) > 0.2 or math.abs(vel.z) > 0.2) then
				-- Horizontal deceleration
				local slip_factor = 4.0 / (slippery + 4)
				self.object:set_acceleration({
					x = -vel.x * slip_factor,
					y = 0,
					z = -vel.z * slip_factor
				})
			elseif vel.y == 0 then
				is_moving = false
			end
		end

		if self.moving_state == is_moving and self.slippery_state == is_slippery then
			-- Do not update anything until the moving state changes
			return
		end

		self.moving_state = is_moving
		self.slippery_state = is_slippery
		
		if is_moving then
			self.object:set_acceleration({x = 0, y = -gravity, z = 0})
		else
			self.object:set_acceleration({x = 0, y = 0, z = 0})
			self.object:set_velocity({x = 0, y = 0, z = 0})
		end
	end,
})
