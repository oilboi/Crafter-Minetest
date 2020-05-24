--items
minetest.register_food("mob:raw_porkchop",{
	description = "Raw Porkchop",
	texture = "raw_porkchop.png",
	satiation=1,
	hunger=2,
})


minetest.register_food("mob:cooked_porkchop",{
	description = "Cooked Porkchop",
	texture = "cooked_porkchop.png",
	satiation=3,
	hunger=5,
})


minetest.register_food("mob:egg",{
	description = "Egg",
	texture = "egg.png",
	satiation=1,
	hunger=3,
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
