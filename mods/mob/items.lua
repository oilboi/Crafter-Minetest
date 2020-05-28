--items
minetest.register_food("mob:raw_porkchop",{
	description = "Raw Porkchop",
	texture = "raw_porkchop.png",
	satiation=10,
	hunger=2,
})


minetest.register_food("mob:cooked_porkchop",{
	description = "Cooked Porkchop",
	texture = "cooked_porkchop.png",
	satiation=20,
	hunger=5,
})


minetest.register_food("mob:egg",{
	description = "Egg",
	texture = "egg.png",
	satiation=5,
	hunger=2,
})

minetest.register_food("mob:carrot",{
	description = "Carrot",
	texture = "carrot.png",
	satiation=2,
	hunger=2,
})

minetest.register_craftitem("mob:slimeball", {
	description = "Slimeball",
	inventory_image = "slimeball.png",
})

minetest.register_craftitem("mob:feather", {
	description = "Feather",
	inventory_image = "feather.png",
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
