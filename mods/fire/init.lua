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
	inventory_image = "fire.png",
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
	collisionbox = {-0.2, -0.2, -0.2, 0.2, 0.2, 0.2},
	visual = "sprite",
	visual_size = {x = 1, y = 1, z = 1},
	textures = {name="fire.png", animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=8.0}},
	spritediv = {x = 1, y = 8},
	initial_sprite_basepos = {x = 0, y = 0},
	is_visible = true,
	pointable = false,
}

fire.on_activate = function(self)
	self.object:set_sprite({x=1,y=math.random(1,8)}, 8, 0.05, false)
end
fire.timer = 0
fire.life = 0
fire.on_step = function(self,dtime)
	if not self.player or (self.player and not self.player:is_player()) then
		self.object:remove()
	end
	if self.master then
		self.timer = self.timer + dtime
		self.life = self.life + dtime
		if self.life >= 7 then
			put_fire_out(self.master)
			return
		end
		if self.timer >= 1 then
			self.timer = 0
			self.player:set_hp(self.player:get_hp()-1)
		end
	end
end
minetest.register_entity("fire:fire",fire)



--this is the handling part

local fire_channels = {}

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	fire_channels[name] = minetest.mod_channel_join(name..":fire_state")

	local meta = player:get_meta()
	if meta:get_int("on_fire") > 0 then
		minetest.after(2,function()
			start_fire(player)
		end)
	end
end)

function start_fire(player)
	local name = player:get_player_name()
	if not fire_table[name] then
		local object_table = {}
		for i = 1,3 do
			local obj = minetest.add_entity(player:get_pos(),"fire:fire")
			if i == 1 then
				obj:get_luaentity().master = player
			end
			obj:get_luaentity().player = player
			obj:set_attach(player, "", vector.new(0,i*5,0),vector.new(0,0,0))
			table.insert(object_table,obj)
		end
		fire_table[name] = object_table
		local meta = player:get_meta()

		fire_channels[name]:send_all("1")
		meta:set_int("on_fire", 1)
	end
end

function put_fire_out(player)
	local name = player:get_player_name()
	if fire_table[name] then
		for _,object in pairs(fire_table[name]) do
			object:remove()
		end
		fire_table[name] = nil

		local meta = player:get_meta()
		fire_channels[name]:send_all("0")
		meta:set_int("on_fire", 0)
	end
end

minetest.register_on_respawnplayer(function(player)
	put_fire_out(player)
end)