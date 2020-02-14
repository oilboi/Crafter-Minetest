--[[

Basic idealogy

keep it simple stupid

make cart make noise

make player able to push cart

make carts push each other away --repel axis

make chest and furnace cart

]]--
local path = minetest.get_modpath("minecart")
dofile(path.."/rail.lua")



local function is_rail(x,y,z)
	return(minetest.get_node_group(minetest.get_node(vector.new(x,y,z)).name,"rail")>0)
end

local minecart = {
	initial_properties = {
		physical = false, -- otherwise going uphill breaks
		collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},--{-0.5, -0.4, -0.5, 0.5, 0.25, 0.5},
		visual = "mesh",
		mesh = "minecart.obj",
		visual_size = {x=1, y=1},
		textures = {"minecart.png"},
		automatic_face_movement_dir = 90.0,
	},

	rider = nil,
	punched = false,
	speed = 0,
	
}

function minecart:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	local player_name = clicker:get_player_name()
	
	if self.rider and player_name == self.rider then
		self.rider = nil
		--carts:manage_attachment(clicker, nil)
	elseif not self.rider then
		self.rider = player_name
		clicker:set_attach(self.object, "", {x=0, y=-4.5, z=0}, {x=0, y=0, z=0})
		--player:set_eye_offset({x=0, y=-4, z=0},{x=0, y=-4, z=0})
		--carts:manage_attachment(clicker, self.object)

		-- player_api does not update the animation
		-- when the player is attached, reset to default animation
		
		--player_api.set_animation(clicker, "stand")
	end
end

function minecart:on_activate(staticdata, dtime_s)
	self.object:set_armor_groups({immortal=1})
	if string.sub(staticdata, 1, string.len("return")) ~= "return" then
		return
	end
	local data = minetest.deserialize(staticdata)
	if type(data) ~= "table" then
		return
	end
	self.railtype = data.railtype
	if data.old_dir then
		self.old_dir = data.old_dir
	end
end

function minecart:get_staticdata()
	return minetest.serialize({
	})
end
function minecart:on_punch(puncher, time_from_last_punch, tool_capabilities, dir, damage)
	self.object:remove()
end






--repel from players on track "push"
function minecart:push(self)
	local pos = self.object:getpos()
	for _,object in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
		if object:is_player() and object:get_player_name() ~= self.rider then
			local player_pos = object:getpos()
			pos.y = 0
			player_pos.y = 0
			
			local vel = vector.subtract(pos, player_pos)
			vel = vector.normalize(vel)
			local distance = vector.distance(pos,player_pos)
			
			distance = (1-distance)*10
			
			vel = vector.multiply(vel,distance)
			
			--only push if it's faster than current speed
			if distance > self.speed then
				self.object:setvelocity(vel)
				self.speed = distance
			end		
		end
	end
end

function minecart:ride_rail(self)
	local pos = vector.floor(vector.add(self.object:getpos(),0.5))
	local speed = self.speed
	if self.speed > 10 then
		self.speed = 10
	end
	
	local vel = self.object:getvelocity()
	local x = math.abs(vel.x)
	local z = math.abs(vel.z)
	local xdir
	local zdir
	local dir = {x=0,y=0,z=0}
	
	--check direction
	--x axis
	if x > z then
		if vel.x>0 then xdir=1 elseif vel.x<0 then xdir=-1 end
		
		--print(minetest.get_node(vector.new(pos.x,pos.y,pos.z)).name)
		
		--go up
		if is_rail(pos.x+xdir,pos.y+1,pos.z) or (not is_rail(pos.x,pos.y,pos.z) and is_rail(pos.x+xdir,pos.y,pos.z)) then
			--print("up")
			dir.y = speed
			dir.x = xdir*speed

		--go down
		elseif (is_rail(pos.x,pos.y-1,pos.z) or vel.y < 0) and not is_rail(pos.x+xdir,pos.y,pos.z) then
			--print("down")
			dir.y = -speed
			dir.x = xdir*speed
		
		--go flat
		elseif is_rail(pos.x,pos.y,pos.z) then --currently on rail
			--print("flat")
			--print("forward inside")
			--correct y position
			if dir.y == 0 and self.object:getpos().y ~= pos.y then
				--print("correcting y")
				local posser = self.object:getpos()
				self.object:moveto(vector.new(posser.x,pos.y,posser.z))
			end
			dir.x = xdir*speed
		end
	--z axis
	elseif z > x then
		if vel.z>0 then zdir=1 elseif vel.z<0 then zdir=-1 end
		
		--print(minetest.get_node(vector.new(pos.x,pos.y,pos.z)).name)
		
		--go up
		if is_rail(pos.x,pos.y+1,pos.z+zdir) or (not is_rail(pos.x,pos.y,pos.z) and is_rail(pos.x,pos.y,pos.z+zdir)) then
			--print("up")
			dir.y = speed
			dir.z = zdir*speed
		
		--go down
		elseif (is_rail(pos.x,pos.y-1,pos.z) or vel.y < 0) and not is_rail(pos.x,pos.y,pos.z+zdir) then
			--print("down")
			dir.y = -speed
			dir.z = zdir*speed
		
		
		--go flat
		elseif is_rail(pos.x,pos.y,pos.z) then --currently on rail
			--print("flat")
			--print("forward inside")
			--correct y position
			if dir.y == 0 and self.object:getpos().y ~= pos.y then
				--print("correcting y")
				local posser = self.object:getpos()
				self.object:moveto(vector.new(posser.x,pos.y,posser.z))
			end
			dir.z = zdir*speed
		end
	end
	--turn
	local turnx = 0
	local turnz = 0
	
	if vel.x>0 then turnx=1 elseif vel.x<0 then turnx=-1 end
	if vel.z>0 then turnz=1 elseif vel.z<0 then turnz=-1 end
	

	if turnx and turnz and dir.y == 0 and not vector.equals(dir, vector.new(0,0,0)) and not is_rail(pos.x+turnx,pos.y-1,pos.z+turnz) and not is_rail(pos.x+turnx,pos.y,pos.z+turnz) and not is_rail(pos.x+turnx,pos.y+1,pos.z+turnz) then
		if x > z then
			for y = -1,1 do
				if is_rail(pos.x,pos.y+y,pos.z+1) then
					dir.z = speed
					dir.x = 0
					--recenter on the rail
					self.object:moveto(pos)
				elseif is_rail(pos.x,pos.y+y,pos.z-1) then
					dir.z = -speed
					dir.x = 0
					--recenter on the rail
					self.object:moveto(pos)
				end
			end
		elseif z > x then
			for y = -1,1 do
				if is_rail(pos.x+1,pos.y+y,pos.z) then
					dir.x = speed
					dir.z = 0
					--recenter on the rail
					self.object:moveto(pos)
				elseif is_rail(pos.x-1,pos.y+y,pos.z) then
					dir.x = -speed
					dir.z = 0
					--recenter on the rail
					self.object:moveto(pos)
				end
			end
		end
		
	end
	--apply
	--if not vector.equals(dir,vector.new(0,0,0)) then
	self.object:setvelocity(dir)
	--end
	self.oldpos=self.object:getpos()
	
	--make the cart move up and down on hills
	self.object:set_properties({mesh="minecart.obj"})
	if vel.y <0  then
		self.object:set_properties({mesh="minecart_down.obj"})
	elseif vel.y > 0 then
		self.object:set_properties({mesh="minecart_up.obj"})
	end
	
	--slow it down
	if self.speed > 0 then
		self.speed = self.speed - 0.01
	end
	if self.speed < 0 then
		self.speed = 0
	end
	
end



function minecart:on_step(dtime)
	minecart:push(self)
	minecart:ride_rail(self)
end

minetest.register_entity("minecart:minecart", minecart)




















minetest.register_craftitem("minecart:minecart", {
	description = "Minecart",
	inventory_image = "minecartitem.png",
	wield_image = "minecartitem.png",
	on_place = function(itemstack, placer, pointed_thing)
		if not pointed_thing.type == "node" then
			return
		end
		
		if minetest.get_item_group(minetest.get_node(pointed_thing.under).name, "rail")>0 then
			minetest.add_entity(pointed_thing.under, "minecart:minecart")
		else
			return
		end

		itemstack:take_item()

		return itemstack
	end,
})

minetest.register_craft({
	output = "minecart:minecart",
	recipe = {
		{"main:iron", "", "main:iron"},
		{"main:iron", "main:iron", "main:iron"},
	},
})
