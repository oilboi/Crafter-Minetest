--[[

Basic idealogy

goal - > go to goal - > check all this and repeat


minecart does check axis dir then -1 1 on opposite axis (x and z)

minecart checks in front and above 

minecart checks in front and below

if in front above start moving up

if in front below start moving down

minecart checks if rail in front then if not check sides and if none then stop

if a rail in front of minecart then when past center of node center, turn towards the available rail and then recenter self onto rail on the new axis


keep it simple stupid

make cart make noise

]]--
local path = minetest.get_modpath("minecart")
dofile(path.."/rail.lua")



local minecart = {
	initial_properties = {
		physical = false, -- otherwise going uphill breaks
		collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		visual = "mesh",
		mesh = "minecart.b3d",
		visual_size = {x=1, y=1},
		textures = {"minecart.png"},
		automatic_face_movement_dir = 90.0,
	},

	rider = nil,
	punched = false,
	
}

function minecart:on_rightclick(clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	local player_name = clicker:get_player_name()
	if self.rider and player_name == self.rider then
		self.rider = nil
		carts:manage_attachment(clicker, nil)
	elseif not self.rider then
		self.rider = player_name
		carts:manage_attachment(clicker, self.object)

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
	for _,object in ipairs(minetest.get_objects_inside_radius(pos, 2)) do
		if object:is_player() then
			local player_pos = object:getpos()
		end
	end
end

function minecart:ride_rail(self)
	if self.goal then
		print("goal: "..dump(self.goal))
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
