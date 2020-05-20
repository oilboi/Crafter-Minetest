--items
minetest.register_craftitem("mob:raw_porkchop", {
	description = "Raw Porkchop",
	inventory_image = "raw_porkchop.png",
	groups = {satiation=1,hunger=2},
})
minetest.register_craftitem("mob:cooked_porkchop", {
	description = "Cooked Porkchop",
	inventory_image = "cooked_porkchop.png",
	groups = {satiation=3,hunger=5},
})

minetest.register_craftitem("mob:slimeball", {
	description = "Slimeball",
	inventory_image = "slimeball.png",
})
minetest.register_craftitem("mob:gunpowder", {
	description = "Gunpowder",
	inventory_image = "gunpowder.png",
})
minetest.register_craftitem("mob:string", {
	description = "String",
	inventory_image = "string.png",
})
--cooking
minetest.register_craft({
	type = "cooking",
	output = "mob:cooked_porkchop",
	recipe = "mob:raw_porkchop",
})
