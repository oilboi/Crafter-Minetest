local minetest = minetest
--grass spread abm
local light
minetest.register_abm({
	label = "Grass Grow",
	nodenames = {"main:dirt"},
	neighbors = {"main:grass", "air"},
	interval = 10,
	chance = 1000,
	action = function(pos)
		light = minetest.get_node_light(pos, nil)
		--print(light)
		if light < 10 then
			return
		end
		minetest.set_node(pos,{name="main:grass"})
	end,
})
