minetest.register_node("craftingtable:craftingtable", {
    description = "Crafting Table",
    tiles = {"crafting_workbench_top.png", "wood.png", "crafting_workbench_side.png",
		"crafting_workbench_side.png", "crafting_workbench_front.png", "crafting_workbench_front.png"},
    groups = {wood = 1, hard = 1, axe = 1, hand = 3,pathable = 1},
    sounds = main.woodSound(),
})
minetest.register_craft({
	output = "craftingtable:craftingtable",
	recipe = {
		{"main:wood","main:wood"},
		{"main:wood","main:wood"}
	}
})
