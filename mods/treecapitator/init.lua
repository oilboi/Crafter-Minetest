treecaptitator = {}

local dropper = {"main:leaves","main:stick","main:apple"}

-- Leafdecay
local function leafdecay_after_destruct(pos, oldnode, def)
	for _, v in pairs(minetest.find_nodes_in_area(vector.subtract(pos, def.radius),
			vector.add(pos, def.radius), def.leaves)) do
		local node = minetest.get_node(v)
		local timer = minetest.get_node_timer(v)
		if node.param2 ~= 1 and not timer:is_started() then
			timer:start((math.random()+math.random())*math.random())
		end
	end
end

local function leafdecay_on_timer(pos, def)
	if minetest.find_node_near(pos, def.radius, def.trunks) then
		return false
	end

	local node = minetest.get_node(pos)
	local drops = minetest.get_node_drops(node.name)
	for _, item in ipairs(drops) do
		local is_leaf
		for _, v in pairs(def.leaves) do
			if v == item then
				is_leaf = true
			end
		end
		if minetest.get_item_group(item, "leafdecay_drop") ~= 0 or not is_leaf then
			minetest.add_item({
				x = pos.x - 0.5 + math.random(),
				y = pos.y - 0.5 + math.random(),
				z = pos.z - 0.5 + math.random(),
			}, item)
		end
	end
	
	minetest.remove_node(pos)
	minetest.check_for_falling(pos)
	
	minetest.add_particlespawner({
		amount = 10,
		time = 0.0001,
		minpos = {x=pos.x-0.5, y=pos.y-0.5, z=pos.z-0.5},
		maxpos = {x=pos.x+0.5, y=pos.y+0.5, z=pos.z+0.5},
		minvel = vector.new(-0.5,0,-0.5),
		maxvel = vector.new(0.5,0,0.5),
		minacc = {x=0, y=-9.81, z=0},
		maxacc = {x=0, y=-9.81, z=0},
		minexptime = 0.5,
		maxexptime = 1.5,
		minsize = 1,
		maxsize = 2,
		collisiondetection = true,
		vertical = false,
		texture = "treecapitator.png"
	})
	minetest.sound_play("leaves", {pos=pos, gain = 0.2, max_hear_distance = 60,pitch = math.random(70,100)/100})
	--random drops - remove this for now
	--if math.random() > 0.75 then
		--local obj = minetest.add_item(pos,dropper[math.random(1,3)])
	--end
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
