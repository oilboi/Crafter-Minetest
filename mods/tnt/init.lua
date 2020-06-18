local minetest,type,vector,math,ipairs = 
minetest,type,vector,math,ipairs


local function extreme_tnt(pos,range,explosion_type)
	local pos = vector.floor(vector.add(pos,0.5))
	local delay = 0
	for x=-1,0 do
	for y=-1,0 do
	for z=-1,0 do
		minetest.after(delay, function(pos,range,x,y,z)
			local min = vector.add(pos,vector.multiply(vector.new(x,y,z),range))
			local max = vector.add(pos,vector.multiply(vector.new(x+1,y+1,z+1),range))
			local vm = minetest.get_voxel_manip()	
			local emin, emax = vm:read_from_map(min,max)
			local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
			local data = vm:get_data()
			local air = minetest.get_content_id("air")
			
			for x=min.x, max.x do
			for y=min.y, max.y do
			for z=min.z, max.z do
				--if vector.distance(pos, vector.new(x,y,z)) <= range then		
				--minetest.remove_node(vector.new(x,y,z))
				data[area:index(x,y,z)] = air
				--end
			end
			end
			end
			vm:set_data(data)
			vm:write_to_map()
		end,pos,range,x,y,z)
		delay = delay + 1
	end
	end
	end
	
	minetest.sound_play("tnt_explode", {pos = pos, gain = 1.0, max_hear_distance = range*range*range})
end
--use raycasting to create actual explosion
local n_pos
local node2
local ray
local stop
local found
local positional_data
local pos2 = vector.new(0,0,0)
local in_node
local in_water
local min
local max
local vm
local emin
local emax
local area
local data
local air = minetest.get_content_id("air")
local content_id = minetest.get_name_from_content_id
local distance
local item
local ppos
local obj
local do_it
local in_node
local clear
local power
local dir
local force
local hp
local explosion_force
local explosion_depletion
local range_calc
function tnt(pos,range,explosion_type)
	in_node = minetest.get_node(pos).name
	in_water =  ( in_node == "main:water" or minetest.get_node(pos).name == "main:waterflow")
	min = vector.add(pos,range)
	max = vector.subtract(pos,range)
	vm = minetest.get_voxel_manip(min,max)
		emin, emax = vm:read_from_map(min,max)
		area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
		data = vm:get_data()
		
	if in_water == false then
		vm:get_light_data()
		range_calc = range/100
		explosion_depletion = range/2
		--raycast explosion
		for x=-range, range do
		for y=-range, range do
		for z=-range, range do
			distance = vector.distance(pos2, vector.new(x,y,z))
			if distance <= range and distance >= range-1 then
				ray = minetest.raycast(pos, vector.new(pos.x+x,pos.y+y,pos.z+z), false, false)
				explosion_force = range
				for pointed_thing in ray do
					explosion_force = explosion_force - math.random()
					if pointed_thing and explosion_force >= explosion_depletion then
						n_pos = area:index(pointed_thing.under.x,pointed_thing.under.y,pointed_thing.under.z)

						if n_pos and data[n_pos] then
							node2 = content_id(data[n_pos])
							
							if node2 == "nether:obsidian" or node2 == "nether:bedrock" then
								break
							elseif node2 == "tnt:tnt" then
								data[n_pos] = air
								minetest.add_entity({x=pointed_thing.under.x,y=pointed_thing.under.y,z=pointed_thing.under.z}, "tnt:tnt",minetest.serialize({do_ignition_particles=true,timer = math.random()}))
							else
								data[n_pos] = air

								minetest.after(0, function(pointed_thing)
									minetest.check_for_falling({x=pointed_thing.under.x,y=pointed_thing.under.y+1,z=pointed_thing.under.z})
								end,pointed_thing)
								if math.random() > 0.9 + range_calc then
									item = minetest.get_node_drops(node2, "main:diamondpick")[1]
									ppos = {x=pointed_thing.under.x,y=pointed_thing.under.y,z=pointed_thing.under.z}
									obj = minetest.add_item(ppos, item)
									if obj then
										power = (range - vector.distance(pos,ppos))*2
										dir = vector.subtract(ppos,pos)
										force = vector.multiply(dir,power)
										obj:set_velocity(force)
									end
								end
							end
						end
					else
						break
					end
				end
			end
		end
		end
		end
		vm:set_data(data)
		vm:update_liquids()
		vm:write_to_map()
	end
	
	minetest.sound_play("tnt_explode", {pos = pos, gain = 1.0, max_hear_distance = range*range}) --hear twice as far away
	
	--throw players and items
	for _,object in ipairs(minetest.get_objects_inside_radius(pos, range)) do
		if object:is_player() or (object:get_luaentity() and (object:get_luaentity().name == "__builtin:item" or object:get_luaentity().name == "tnt:tnt" or object:get_luaentity().is_mob == true)) then
			do_it = true
			if not object:is_player() and object:get_luaentity().name == "tnt:tnt" then
				in_node = minetest.get_node(object:get_pos()).name
				if ( in_node == "main:water" or in_node == "main:waterflow") then
					do_it = false
				end
			end
			if do_it == true then
				ppos = object:get_pos()
				if object:is_player() then
					ppos.y = ppos.y + 1
				end
				ray = minetest.raycast(pos, ppos, false, false)
				clear = true
				for pointed_thing in ray do
					n_pos = area:index(pointed_thing.under.x,pointed_thing.under.y,pointed_thing.under.z)
					node2 = content_id(data[n_pos])
					if node2 == "nether:obsidian" or node2 == "nether:bedrock" then
						clear = false
					end
				end
				if clear == true then
					power = (range - vector.distance(pos,ppos))*10
					dir = vector.direction(pos,ppos)
					force = vector.multiply(dir,power)
					if object:is_player() then
						--damage the player
						hp = object:get_hp()
						if hp > 0 then
							--object:set_hp(hp - math.floor(power*2))
							object:punch(object, 2, 
								{
								full_punch_interval=1.5,
								damage_groups = {damage=math.floor(power)},
								})
						end
						object:add_player_velocity(force)
					elseif object:get_luaentity() and (object:get_luaentity().name == "__builtin:item" or object:get_luaentity().name == "tnt:tnt" or object:get_luaentity().is_mob == true)  then
						if object:get_luaentity().name == "tnt:tnt" then
							object:get_luaentity().shot = true
						elseif object:get_luaentity().is_mob == true then
							object:punch(object, 2, 
								{
								full_punch_interval=1.5,
								damage_groups = {damage=math.floor(power)},
								})
						elseif object:get_luaentity().name == "__builtin:item" then
							object:get_luaentity().poll_timer = 0
						end
						object:set_velocity(force)
					end
				end
			end
		end
	end
	
	--stop client from lagging
	if range > 15 then
		range = 15
	end
	

	minetest.add_particlespawner({
		amount = range,
		time = 0.001,
		minpos = pos,
		maxpos = pos,
		minvel = vector.new(-range,-range,-range),
		maxvel = vector.new(range,range,range),
		minacc = {x=0, y=0, z=0},
		maxacc = {x=0, y=0, z=0},
		minexptime = 1.1,
		maxexptime = 1.5,
		minsize = 1,
		maxsize = 2,
		collisiondetection = true,
		collision_removal = true,
		vertical = false,
		texture = "smoke.png",
	})
end


minetest.register_entity("tnt:tnt", {
	initial_properties = {
		hp_max = 1,
		physical = true,
		collide_with_objects = false,
		collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		visual = "cube",
		visual_size = {x = 1, y = 1},
		textures = {"tnt_top.png", "tnt_bottom.png",
			"tnt_side.png", "tnt_side.png",
			"tnt_side.png", "tnt_side.png"},
		is_visible = true,
		pointable = true,
	},

	timer = 5,
	timer_max = 5, --this has to be equal to timer
	range = 7,
	get_staticdata = function(self)
		return minetest.serialize({
			range = self.range,
			timer = self.timer,
			exploded = self.exploded,	
		})
	end,
	
	on_activate = function(self, staticdata, dtime_s)
		self.object:set_armor_groups({immortal = 1})
		self.object:set_velocity({x = math.random(-3,3), y = 3, z = math.random(-3,3)})
		self.object:set_acceleration({x = 0, y = -9.81, z = 0})
		if string.sub(staticdata, 1, string.len("return")) == "return" then
			local data = minetest.deserialize(staticdata)
			if data and type(data) == "table" then
				self.range = data.range
				self.timer = data.timer
				self.exploded = data.exploded
			end
		end
		if self.timer == self.timer_max then
			minetest.add_particlespawner({
				amount = 10,
				time = 0,
				minpos = vector.new(0,0.5,0),
				minpos = vector.new(0,0.5,0),
				minvel = vector.new(-0.5,1,-0.5),
				maxvel = vector.new(0.5,5,0.5),
				minacc = {x=0, y=0, z=0},
				maxacc = {x=0, y=0, z=0},
				minexptime = 0.5,
				maxexptime = 1.0,
				minsize = 1,
				maxsize = 2,
				collisiondetection = false,
				vertical = false,
				texture = "smoke.png",
				attached = self.object,
			})
			minetest.sound_play("tnt_ignite", {object = self.object, gain = 1.0, max_hear_distance = self.range*self.range*self.range})
		end
	end,
		
	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		local obj = minetest.add_item(self.object:get_pos(), "tnt:tnt")
		self.object:remove()
	end,

	sound_played = false,
	on_step = function(self, dtime)	
		self.timer = self.timer - dtime
		if not self.shot or not self.redstone_activated then
			local vel = self.object:getvelocity()
			vel = vector.multiply(vel,-0.05)
			self.object:add_velocity(vector.new(vel.x,0,vel.z))
		end
		if self.timer <= 0 then
			if not self.range then
				self.range = 7
			end
			tnt(self.object:get_pos(),self.range)
			self.object:remove()
		end
	end,
})


minetest.register_node("tnt:tnt", {
    description = "TNT",
    tiles = {"tnt_top.png", "tnt_bottom.png",
			"tnt_side.png", "tnt_side.png",
			"tnt_side.png", "tnt_side.png"},
    groups = {stone = 2, hard = 1, pickaxe = 2, hand = 4, redstone_activation = 1},
    sounds = main.stoneSound(),
    redstone_activation = function(pos)
		local obj = minetest.add_entity(pos,"tnt:tnt")
		local range = 4
		obj:get_luaentity().range = range
		obj:get_luaentity().redstone_activated = true
		minetest.remove_node(pos)
    end,
    on_punch = function(pos, node, puncher, pointed_thing)
		local obj = minetest.add_entity(pos,"tnt:tnt")
		local range = 4
		obj:get_luaentity().range = range
		minetest.remove_node(pos)
    end,
})

minetest.register_node("tnt:uranium_tnt", {
    description = "Uranium TNT",
    tiles = {"tnt_top.png^[colorize:green:100", "tnt_bottom.png^[colorize:green:100",
			"tnt_side.png^[colorize:green:100", "tnt_side.png^[colorize:green:100",
			"tnt_side.png^[colorize:green:100", "tnt_side.png^[colorize:green:100"},
    groups = {stone = 2, hard = 1, pickaxe = 2, hand = 4},
    sounds = main.stoneSound(),
    on_punch = function(pos, node, puncher, pointed_thing)
		local obj = minetest.add_entity(pos,"tnt:tnt")
		local range = 50
		obj:get_luaentity().range = range
		obj:get_luaentity().timer = 7
		obj:get_luaentity().extreme = true
		
		minetest.remove_node(pos)
    end,
})

minetest.register_node("tnt:uh_oh", {
    description = "Uh Oh",
    tiles = {"tnt_top.png", "tnt_bottom.png",
			"tnt_side.png", "tnt_side.png",
			"tnt_side.png", "tnt_side.png"},
    groups = {stone = 2, hard = 1, pickaxe = 2, hand = 4},
    sounds = main.stoneSound(),
    on_construct = function(pos)
		local range = 5
		for x=-range, range do
		for y=-range, range do
		for z=-range, range do 
			minetest.add_node(vector.new(pos.x+x,pos.y+y,pos.z+z),{name="tnt:tnt"})
		end
		end
		end
    end,
})



minetest.register_craft({
	output = "tnt:tnt",
	recipe = {
		{"mob:gunpowder", "main:sand",     "mob:gunpowder"},
		{"main:sand",     "mob:gunpowder", "main:sand"},
		{"mob:gunpowder", "main:sand",     "mob:gunpowder"},
	},
})
