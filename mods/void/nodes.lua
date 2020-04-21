local tool = {"main:woodpick","ain:stonepick","main:ironpick","main:goldpick","main:diamondpick"}

minetest.register_node("void:stone", {
    description = "Void Stone",
    tiles = {"stone.png^[colorize:black:120"},
    groups = {stone = 1, hand = 1,pathable = 1},
    sounds = main.stoneSound(),
    drop = "",
	})
