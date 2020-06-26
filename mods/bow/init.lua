local 
minetest,math,vector,ipairs,string,type
= 
minetest,math,vector,ipairs,string,type

-- minetest library
local get_connected_players     = minetest.get_connected_players
local get_player_by_name        = minetest.get_player_by_name
local get_objects_inside_radius = minetest.get_objects_inside_radius
local create_raycast            = minetest.raycast
local dir_to_yaw                = minetest.dir_to_yaw
local deserialize               = minetest.deserialize
local serialize                 = minetest.serialize

-- string library
local s_sub  = string.sub
local s_len  = string.len

-- math library
local pi     = math.pi
local random = math.random
local floor  = math.floor

-- vector library
local new_vec = vector.new
local floor_vec = vector.floor
local vec_distance = vector.distance
local normalize_vec = vector.normalize
local add_vec = vector.add
local sub_vec = vector.subtract
local multiply_vec = vector.multiply
local divide_vec = vector.divide
local vec_direction = vector.direction


--[[
██████╗ ██╗      █████╗ ██╗   ██╗███████╗██████╗     ██████╗  █████╗ ██████╗ ████████╗
██╔══██╗██║     ██╔══██╗╚██╗ ██╔╝██╔════╝██╔══██╗    ██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝
██████╔╝██║     ███████║ ╚████╔╝ █████╗  ██████╔╝    ██████╔╝███████║██████╔╝   ██║   
██╔═══╝ ██║     ██╔══██║  ╚██╔╝  ██╔══╝  ██╔══██╗    ██╔═══╝ ██╔══██║██╔══██╗   ██║   
██║     ███████╗██║  ██║   ██║   ███████╗██║  ██║    ██║     ██║  ██║██║  ██║   ██║   
╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝    ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   
]]--


-- data pool
local pool = {}

--this is a very complicated function which makes the bow work
local temp_pool
local player
local new_index
local rightclick
local inv
local dir
local vel
local pos
local object
local function arrow_check(name,dtime)
	temp_pool = pool[name]
	player = get_player_by_name(name)
	rightclick = player:get_player_control().RMB
	new_index = player:get_wield_index()

	-- if player changes selected item
	if new_index ~= temp_pool.index then
		inv:set_stack("main", temp_pool.index, ItemStack("bow:bow_empty"))
		pool[name] = nil
		return
	end

	-- if player lets go of rightclick
	if temp_pool.step ~= 5 and not rightclick then
		inv:set_stack("main", temp_pool.index, ItemStack("bow:bow_empty"))
		pool[name] = nil
		return
	end

	-- if player isn't holding a bow
	if minetest.get_item_group(player:get_wielded_item():get_name(), "bow") == 0 then
		pool[name] = nil
		return
	end

	inv = player:get_inventory()

	-- if player doesn't have any arrows
	if not inv:contains_item("main", ItemStack("bow:arrow")) then
		inv:set_stack("main", temp_pool.index, ItemStack("bow:bow_empty"))
		pool[name] = nil
		return
	end

	-- count steps using dtime
	if temp_pool.step < 5 then

	temp_pool.float = temp_pool.float + dtime

	if temp_pool.float > 0.05 then
		temp_pool.float = 0
		temp_pool.step  = temp_pool.step + 1
		player:set_wielded_item(ItemStack("bow:bow_"..temp_pool.step))
	end

	end

	if temp_pool.step == 5 and not rightclick then
		
		dir = player:get_look_dir()
		vel = multiply_vec(dir,50)
		pos = player:get_pos()
		pos.y = pos.y + 1.5	

		object = minetest.add_entity(add_vec(pos,divide_vec(dir,10)),"bow:arrow")
		object:set_velocity(vel)
		object:get_luaentity().owner  = name
		object:get_luaentity().oldpos = pos
		
		minetest.sound_play("bow", {object=player, gain = 1.0, max_hear_distance = 60,pitch = random(80,100)/100})

		inv:remove_item("main", ItemStack("bow:arrow"))
		inv:set_stack("main", temp_pool.index, ItemStack("bow:bow_empty"))

		pool[name] = nil
	end


	--add hand fatigue timer
	--gradually increase fatigue until cap is reached

end

minetest.register_globalstep(function(dtime)
	for name in pairs(pool) do
		arrow_check(name,dtime)
	end
end)


--[[
 █████╗ ██████╗ ██████╗  ██████╗ ██╗    ██╗    ███████╗██╗   ██╗███╗   ██╗ ██████╗████████╗██╗ ██████╗ ███╗   ██╗███████╗
██╔══██╗██╔══██╗██╔══██╗██╔═══██╗██║    ██║    ██╔════╝██║   ██║████╗  ██║██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
███████║██████╔╝██████╔╝██║   ██║██║ █╗ ██║    █████╗  ██║   ██║██╔██╗ ██║██║        ██║   ██║██║   ██║██╔██╗ ██║███████╗
██╔══██║██╔══██╗██╔══██╗██║   ██║██║███╗██║    ██╔══╝  ██║   ██║██║╚██╗██║██║        ██║   ██║██║   ██║██║╚██╗██║╚════██║
██║  ██║██║  ██║██║  ██║╚██████╔╝╚███╔███╔╝    ██║     ╚██████╔╝██║ ╚████║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║███████║
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝  ╚══╝╚══╝     ╚═╝      ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝
]]--

local pos
local vel
local owner
local pos2
local player_velocity
local direction
local distance
local multiplier
local velocity
local collision
local ray
local dir
local y
local x
local function arrow_step(self, dtime,moveresult)
	self.timer = self.timer + dtime

	pos = self.object:get_pos()
	vel = self.object:get_velocity()
	
	if self.collecting == true then
		owner = get_player_by_name(self.owner)
		for _,object in ipairs(get_objects_inside_radius(pos, self.radius)) do
			
			if owner then
				self.object:set_acceleration(new_vec(0,0,0))

				--get the variables
				pos2 = owner:get_pos()
				player_velocity = owner:get_player_velocity()
				pos2.y = pos2.y + self.collection_height
								
				direction = normalize_vec(sub_vec(pos2,pos))
				distance = vec_distance(pos2,pos)
								
				
				--remove if too far away
				if distance > self.radius then
					distance = 0
				end
								
				multiplier = (self.radius*5) - distance
				velocity = multiply_vec(direction,multiplier)
				
				velocity = add_vec(player_velocity,velocity)
				
				self.object:set_velocity(velocity)
				
				if distance < 0.2 then
					self.object:remove()
				end
				
				return
			else
				print(self.owner.." does not exist")
				self.object:remove()
			end
		end
	else
		for _,object in ipairs(get_objects_inside_radius(pos, 2)) do
			if self.stuck == false and ((object:is_player() and object:get_player_name() ~= self.owner and object:get_hp() > 0) or (object:get_luaentity() and object:get_luaentity().mobname)) then
				object:punch(self.object, 2, 
					{
					full_punch_interval=1.5,
					damage_groups = {damage=3},
				})

				self.object:remove()
				return
			elseif self.timer > 3 and (object:is_player() and object:get_player_name() == self.owner) then
				self.collecting = true
				local inv = object:get_inventory()
				if inv and inv:room_for_item("main", ItemStack("bow:arrow")) then
					inv:add_item("main",ItemStack("bow:arrow"))
					minetest.sound_play("pickup", {
						to_player = object:get_player_name(),
						gain = 0.4,
						pitch = random(60,100)/100
					})
				else
					self.object:remove()
					minetest.throw_item(pos,"bow:arrow")
				end
			end
		end

		if moveresult and moveresult.collides and moveresult.collisions and moveresult.collisions[1] and moveresult.collisions[1].new_velocity and self.stuck == false then
			
			collision = moveresult.collisions[1]

			if collision.new_velocity.x == 0 and collision.old_velocity.x ~= 0 then
				self.check_dir = vec_direction(new_vec(pos.x,0,0),new_vec(collision.node_pos.x,0,0))
			elseif collision.new_velocity.y == 0 and collision.old_velocity.y ~= 0 then
				self.check_dir = vec_direction(new_vec(0,pos.y,0),new_vec(0,collision.node_pos.y,0))
			elseif collision.new_velocity.z == 0 and collision.old_velocity.z ~= 0 then
				self.check_dir = vec_direction(new_vec(0,0,pos.z),new_vec(0,0,collision.node_pos.z))
			end
			if collision.new_pos then
				--print(dump(collision.new_pos))
				self.object:set_pos(collision.new_pos)
			end
			--print(dump(collision.new_pos))
			minetest.sound_play("arrow_hit",{object=self.object,gain=1,pitch=random(80,100)/100,max_hear_distance=64})
			self.stuck = true
			self.object:set_velocity(new_vec(0,0,0))
			self.object:set_acceleration(new_vec(0,0,0))
		elseif self.stuck == true and self.check_dir then
			pos2 = add_vec(pos,multiply_vec(self.check_dir,0.2))
			
			ray = create_raycast(pos, pos2, false, false)

			if not ray:next() then
				self.stuck = false
				self.object:set_acceleration(new_vec(0,-9.81,0))
			end
		end
		
		if not self.stuck and pos and self.oldpos then
			self.spin = self.spin + (dtime*10)
			if self.spin > pi then
				self.spin = -pi
			end

			dir = normalize_vec(sub_vec(pos,self.oldpos))
			y = dir_to_yaw(dir)
			x = (dir_to_yaw(new_vec(vec_distance(new_vec(pos.x,0,pos.z),new_vec(self.oldpos.x,0,self.oldpos.z)),0,pos.y-self.oldpos.y))+(pi/2))
			self.object:set_rotation(new_vec(x,y,self.spin))
		end
		if self.stuck == false then
			self.oldpos = pos
			self.oldvel = vel
		end
	end
end


--[[
 █████╗ ██████╗ ██████╗  ██████╗ ██╗    ██╗    ███████╗███╗   ██╗████████╗██╗████████╗██╗   ██╗
██╔══██╗██╔══██╗██╔══██╗██╔═══██╗██║    ██║    ██╔════╝████╗  ██║╚══██╔══╝██║╚══██╔══╝╚██╗ ██╔╝
███████║██████╔╝██████╔╝██║   ██║██║ █╗ ██║    █████╗  ██╔██╗ ██║   ██║   ██║   ██║    ╚████╔╝ 
██╔══██║██╔══██╗██╔══██╗██║   ██║██║███╗██║    ██╔══╝  ██║╚██╗██║   ██║   ██║   ██║     ╚██╔╝  
██║  ██║██║  ██║██║  ██║╚██████╔╝╚███╔███╔╝    ███████╗██║ ╚████║   ██║   ██║   ██║      ██║   
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝  ╚══╝╚══╝     ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═╝   ╚═╝      ╚═╝   
]]--



local arrow = {}
arrow.initial_properties = {
	physical = true,
	collide_with_objects = false,
	collisionbox = {-0.05, -0.05, -0.05, 0.05, 0.05, 0.05},
	visual = "mesh",
	visual_size = {x = 1 , y = 1},
	mesh = "basic_bow_arrow.b3d",
	textures = {
		"basic_bow_arrow_uv.png"
	},
	pointable = false,
	--automatic_face_movement_dir = 0.0,
	--automatic_face_movement_max_rotation_per_sec = 600,
}
arrow.on_activate = function(self, staticdata, dtime_s)
	--self.object:set_animation({x=0,y=180}, 15, 0, true)
	local vel = nil
	if s_sub(staticdata, 1, s_len("return")) == "return" then
		local data = deserialize(staticdata)
		if data and type(data) == "table" then
			self.spin       = data.spin
			self.owner      = data.owner
			self.stuck      = data.stuck
			self.timer      = data.timer
			self.collecting = data.collecting
			self.check_dir  = data.check_dir
			vel             = data.vel
		end
	end
	if not self.stuck then
		self.object:set_acceleration(new_vec(0,-9.81,0))
		if vel then
			self.object:set_velocity(vel)
		end
	end
end

arrow.get_staticdata = function(self)
	return serialize({
		spin       = self.spin,
		owner      = self.owner,
		stuck      = self.stuck,
		timer      = self.timer,
		collecting = self.collecting,
		check_dir  = self.check_dir,
		vel        = self.object:get_velocity()
	})
end

arrow.spin = 0
arrow.owner = ""
arrow.stuck = false
arrow.timer = 0
arrow.collecting = false
arrow.collection_height = 0.5
arrow.radius = 2

arrow.on_step = function(self, dtime,moveresult)
	arrow_step(self, dtime,moveresult)
end
minetest.register_entity("bow:arrow", arrow)



--[[
██╗████████╗███████╗███╗   ███╗███████╗
██║╚══██╔══╝██╔════╝████╗ ████║██╔════╝
██║   ██║   █████╗  ██╔████╔██║███████╗
██║   ██║   ██╔══╝  ██║╚██╔╝██║╚════██║
██║   ██║   ███████╗██║ ╚═╝ ██║███████║
╚═╝   ╚═╝   ╚══════╝╚═╝     ╚═╝╚══════╝
]]--

local inv
local function initialize_pullback(player)
	inv = player:get_inventory()
	if inv:contains_item("main", ItemStack("bow:arrow")) then
		name = player:get_player_name()
		pool[name] = {}
		pool[name].index = player:get_wield_index()
		pool[name].float = 0
		pool[name].step  = 0
		minetest.sound_play("bow_pull_back", {object=player, gain = 1.0, max_hear_distance = 60,pitch = random(70,110)/100})
	end
end


minetest.register_craftitem("bow:bow_empty", {
	description = "Bow",
	inventory_image = "bow.png",
	stack_max = 1,
	groups = {bow=1},
	range = 0,
	on_secondary_use = function(itemstack, user, pointed_thing)
		initialize_pullback(user)
	end,
	on_place = function(itemstack, placer, pointed_thing)
		initialize_pullback(placer)
	end,
})

for i = 1,5 do
	minetest.register_craftitem("bow:bow_"..i, {
		description = "Bow",
		inventory_image = "bow_"..i..".png",
		stack_max = 1,
		groups = {bow=1,bow_loaded=i},
		range = 0,
		on_drop = function(itemstack, dropper, pos)
			itemstack = ItemStack("bow:bow_empty")
			minetest.item_drop(itemstack, dropper, pos)
			return(itemstack)
		end,
	})
end

minetest.register_craftitem("bow:arrow", {
	description = "Arrow",
	inventory_image = "arrow_item.png",
})



--[[
 ██████╗██████╗  █████╗ ███████╗████████╗██╗███╗   ██╗ ██████╗ 
██╔════╝██╔══██╗██╔══██╗██╔════╝╚══██╔══╝██║████╗  ██║██╔════╝ 
██║     ██████╔╝███████║█████╗     ██║   ██║██╔██╗ ██║██║  ███╗
██║     ██╔══██╗██╔══██║██╔══╝     ██║   ██║██║╚██╗██║██║   ██║
╚██████╗██║  ██║██║  ██║██║        ██║   ██║██║ ╚████║╚██████╔╝
 ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝        ╚═╝   ╚═╝╚═╝  ╚═══╝ ╚═════╝ 
]]--


minetest.register_craft({
	output = "bow:bow_empty",
	recipe = {
		{""           , "main:stick", "mob:string"},
		{"main:stick" , ""          , "mob:string"},
		{""           , "main:stick", "mob:string"},
	},
})

minetest.register_craft({
	output = "bow:arrow 16",
	recipe = {
		{"main:iron", ""          , ""           },
		{""         , "main:stick", ""           },
		{""         , ""          , "mob:feather"},
	},
})