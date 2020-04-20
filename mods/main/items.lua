--item definition

minetest.register_craftitem("main:apple", {
	description = "Apple",
	inventory_image = "apple.png",
	health = 1,
})

minetest.register_craftitem("main:stick", {
	description = "Stick",
	inventory_image = "stick.png",
	groups = {stick = 1}
})

minetest.register_craftitem("main:coal", {
	description = "Coal",
	inventory_image = "coal.png",
	groups = {coal = 1}
})

minetest.register_craftitem("main:charcoal", {
	description = "Charcoal",
	inventory_image = "charcoal.png",
	groups = {coal = 1}
})

minetest.register_craftitem("main:iron", {
	description = "Iron",
	inventory_image = "iron.png",
})

minetest.register_craftitem("main:gold", {
	description = "Gold",
	inventory_image = "gold.png",
})

minetest.register_craftitem("main:diamond", {
	description = "Diamond",
	inventory_image = "diamond.png",
})
minetest.register_craftitem("main:flint", {
	description = "Flint",
	inventory_image = "flint.png",
})
