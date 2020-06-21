local
minetest,vector,pairs,math
=
minetest,vector,pairs,math

local treecaptitator = {}

-- Leafdecay
local function leafdecay_after_destruct(pos, oldnode, def)
	for _, v in pairs(minetest.find_nodes_in_area(vector.subtract(pos, def.radius),
			vector.add(pos, def.radius), def.leaves)) do
		local node = minetest.get_node(v)
		local timer = minetest.get_node_timer(v)
		if node.param2 ~= 1 and not timer:is_started() then
			timer:start(math.random()+math.random()+math.random())
		end
	end
end

local function leafdecay_on_timer(pos, def)
	if minetest.find_node_near(pos, def.radius, def.trunks) then
		return false
	end

	minetest.dig_node(pos)
	
	
	minetest.add_particlespawner({
		amount = 20,
		time = 0.0001,
		minpos = {x=pos.x-0.5, y=pos.y-0.5, z=pos.z-0.5},
		maxpos = {x=pos.x+0.5, y=pos.y+0.5, z=pos.z+0.5},
		minvel = vector.new(-1,0,-1),
		maxvel = vector.new(1,0,1),
		minacc = {x=0, y=-9.81, z=0},
		maxacc = {x=0, y=-9.81, z=0},
		minexptime = 0.5,
		maxexptime = 1.5,
		minsize = 0,
		maxsize = 0,
		collisiondetection = true,
		vertical = false,
		node = {name= def.leaves[1]},
	})
	minetest.sound_play("leaves", {pos=pos, gain = 0.2, max_hear_distance = 60,pitch = math.random(70,100)/100})
end

function treecaptitator.register_leafdecay(def)
	assert(def.leaves)
	assert(def.trunks)
	assert(def.radius)
	for _, v in pairs(def.trunks) do
		minetest.override_item(v, {
			after_destruct = function(pos, oldnode)
				leafdecay_after_destruct(pos, oldnode, def)
			end,
		})
	end
	for _, v in pairs(def.leaves) do
		minetest.override_item(v, {
			on_timer = function(pos)
				leafdecay_on_timer(pos, def)
			end,
		})
	end
end

----------------------------- registration
treecaptitator.register_leafdecay({
	trunks = {"main:tree"},
	leaves = {"main:leaves"},
	radius = 2,
})
