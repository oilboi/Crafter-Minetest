minetest.register_craft({
	output = "hopper:hopper",
	recipe = {
		{"main:iron","utility:chest","main:iron"},
		{"","main:iron",""},
	}
})

minetest.register_craft({
	output = "hopper:chute",
	recipe = {
		{"main:iron","utility:chest","main:iron"},
	}
})

minetest.register_craft({
	output = "hopper:sorter",
	recipe = {
		{"","main:gold",""},
		{"main:iron","utility:chest","main:iron"},
		{"","main:iron",""},
	}
})

if not hopper.config.single_craftable_item then
	minetest.register_craft({
		output = "hopper:hopper_side",
		recipe = {
			{"main:iron","utility:chest","main:iron"},
			{"","","main:iron"},
		}
	})
	
	minetest.register_craft({
		output = "hopper:hopper_side",
		type="shapeless",
		recipe = {"hopper:hopper"},
	})

	minetest.register_craft({
		output = "hopper:hopper",
		type="shapeless",
		recipe = {"hopper:hopper_side"},
	})
end
