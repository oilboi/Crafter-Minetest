minetest.register_node("fire:fire", {
    description = "Fire",
    drawtype = "firelike",
	tiles = {
		{
			name = "fire.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 0.3
			},
		},
	},
	--inventory_image = "fire.png",
    groups = {dig_immediate = 1,fire=1,hurt_inside=1},
    sounds = main.stoneSound(),
    floodable = true,
    drop = "",
    walkable = false,
    is_ground_content = false,
    light_source = 11, --debugging
    on_construct = function(pos)
		local under = minetest.get_node(vector.new(pos.x,pos.y-1,pos.z)).name
		--makes nether portal
		if under == "nether:obsidian" then
			minetest.remove_node(pos)
			create_nether_portal(pos)
		--fire lasts forever on netherrack
		elseif under ~= "nether:netherrack" then
			local timer = minetest.get_node_timer(pos)
			timer:start(math.random(0,2)+math.random())
		end
    end,
    on_timer = function(pos, elapsed)
	    local find_flammable = minetest.find_nodes_in_area(vector.subtract(pos,1), vector.add(pos,1), {"group:flammable"})
	    --print(dump(find_flammable))
	    
	    for _,p_pos in pairs(find_flammable) do
		    if math.random() > 0.9 then
				minetest.set_node(p_pos,{name="fire:fire"})
				local timer = minetest.get_node_timer(p_pos)
				timer:start(math.random(0,2)+math.random())
			end
	    end
	    
	    if math.random() > 0.85 then
			minetest.remove_node(pos)
		else
			local timer = minetest.get_node_timer(pos)
			timer:start(math.random(0,2)+math.random())
		end
    end,
})

--flint and steel
minetest.register_tool("fire:flint_and_steel", {
	description = "Flint and Steel",
	inventory_image = "flint_and_steel.png",
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if minetest.get_node(pointed_thing.above).name ~= "air" then
			minetest.sound_play("flint_failed", {pos=pointed_thing.above})
			return
		end
		
		--can't make fire in the aether
		if pointed_thing.above.y >= 20000 then
			minetest.sound_play("flint_failed", {pos=pointed_thing.above,pitch=math.random(75,95)/100})
			return
		end
		
		minetest.add_node(pointed_thing.above,{name="fire:fire"})
		minetest.sound_play("flint_and_steel", {pos=pointed_thing.above})
		itemstack:add_wear(100)
		return(itemstack)
	end,
	tool_capabilities = {
		groupcaps={
			_namespace_reserved = {times={[1]=5555}, uses=0, maxlevel=1},
		},
	},
	groups = {flint=1},
	sound = {breaks = {name="tool_break",gain=0.4}},
})

minetest.register_craft({
	type = "shapeless",
	output = "fire:flint_and_steel",
	recipe = {"main:flint","main:iron"},
})


fire_table = {}

local fire = {}

fire.initial_properties = {
	hp_max = 1,
	physical = false,
	collide_with_objects = false,
	collisionbox = {0, 0, 0, 0, 0, 0},
	visual = "cube",
	textures = {"nothing.png","nothing.png","fire.png","fire.png","fire.png","fire.png"},
	visual_size = {x = 1, y = 1, z = 1},
	--textures = {"nothing.png","nothing.png","fire.png","fire.png","fire.png","fire.png"},--, animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=8.0}},
	is_visible = true,
	pointable = false,
}

fire.on_activate = function(self)
	local texture_list = {
		"nothing.png",
		"nothing.png",
		"fire.png^[opacity:180^[verticalframe:8:0",
		"fire.png^[opacity:180^[verticalframe:8:0",
		"fire.png^[opacity:180^[verticalframe:8:0",
		"fire.png^[opacity:180^[verticalframe:8:0",
	}
	self.object:set_properties({textures=texture_list})
end
--animation stuff
fire.frame = 0
fire.frame_timer = 0
fire.frame_update = function(self)
	self.frame = self.frame + 1
	if self.frame > 7 then
		self.frame = 0
	end
	local texture_list = {
		"nothing.png",
		"nothing.png",
		"fire.png^[opacity:180^[verticalframe:8:"..self.frame,
		"fire.png^[opacity:180^[verticalframe:8:"..self.frame,
		"fire.png^[opacity:180^[verticalframe:8:"..self.frame,
		"fire.png^[opacity:180^[verticalframe:8:"..self.frame,
	}
	self.object:set_properties({textures=texture_list})
end
fire.glow = -1
fire.timer = 0
fire.life = 0
fire.on_step = function(self,dtime)	
	--master is the flag of the entity that controls the hurt
	--owner is the flag that tells the entity who to hurt
	if self.owner and (self.owner:is_player() or self.owner:get_luaentity()) then
		if self.master then
			self.timer = self.timer + dtime
			self.life = self.life + dtime
	
			if self.life >= 7 then
				put_fire_out(self.owner)
				self.object:remove()
				return
			end
			
			if self.timer >= 1 then
				self.timer = 0
				if self.owner:is_player() then
					self.owner:set_hp(self.owner:get_hp()-1)
				elseif self.owner and self.owner:get_luaentity() then
					self.owner:punch(self.object, 2, 
						{
						full_punch_interval=0,
						damage_groups = {damage=2},
					})
				end
			end
		end
	else
		self.object:remove()
	end
	self.frame_timer = self.frame_timer + dtime
	if self.frame_timer >= 0.015 then
		self.frame_timer = 0
		self.frame_update(self)
	end
end
minetest.register_entity("fire:fire",fire)



--this is the handling part

local fire_channels = {}

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	fire_channels[name] = minetest.mod_channel_join(name..":fire_state")

	minetest.after(4,function()
		if not player:is_player() then return end
		local meta = player:get_meta()
		if meta:get_int("on_fire") > 0 then
			start_fire(player)
		end
	end)
end)

function start_fire(object)
	if object:is_player() then
		local name = object:get_player_name()
		if not fire_table[name] then
			local obj = minetest.add_entity(object:get_pos(),"fire:fire")
			obj:get_luaentity().master = true
			obj:get_luaentity().owner = object
			obj:set_attach(object, "", vector.new(0,11,0),vector.new(0,0,0))
			obj:set_properties({visual_size=vector.new(1,2,1)})
			fire_table[name] = obj

			local meta = object:get_meta()
			fire_channels[name]:send_all("1")
			meta:set_int("on_fire", 1)
		end
	elseif object and object:get_luaentity() then
		object:get_luaentity().on_fire = true
		local divisor = object:get_properties().visual_size.y
		local obj = minetest.add_entity(object:get_pos(),"fire:fire")
		--obj:set_properties
		obj:get_luaentity().master = true
		obj:get_luaentity().owner = object

		local fire_table = object:get_luaentity().fire_table
		obj:set_attach(object, "", fire_table.position,vector.new(0,0,0))
		obj:set_properties({visual_size=fire_table.visual_size})

		object:get_luaentity().fire_entity = obj
	end
end

function put_fire_out(object)
	if object:is_player() then
		local name = object:get_player_name()
		if fire_table[name] then
			local obj = fire_table[name]
			if obj:get_luaentity() then
				obj:remove()
			end
			fire_table[name] = nil

			local meta = object:get_meta()
			fire_channels[name]:send_all("0")
			meta:set_int("on_fire", 0)
		end
	elseif object and object:get_luaentity() then
		object:get_luaentity().on_fire = false
		object:get_luaentity().fire_entity = nil
	end
end

minetest.register_on_respawnplayer(function(player)
	put_fire_out(player)
end)