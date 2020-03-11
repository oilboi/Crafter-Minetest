--this is where the crafting bench is defined

minetest.register_node("craftingtable:craftingtable", {
    description = "Crafting Table",
    tiles = {"crafting_workbench_top.png", "wood.png", "crafting_workbench_side.png",
		"crafting_workbench_side.png", "crafting_workbench_front.png", "crafting_workbench_front.png"},
    groups = {wood = 1, hard = 1, axe = 1, hand = 3,pathable = 1},
    sounds = main.woodSound(),
    on_rightclick = function(pos, node, player, itemstack)
		player:get_inventory():set_width("craft", 3)
		player:get_inventory():set_size("craft", 9)

		local form = "size[9,8.75]"..
		"background[-0.19,-0.25;9.41,9.49;crafting_inventory_workbench.png]"..
		"list[current_player;main;0,4.5;9,1;]".. --hot bar
		"list[current_player;main;0,6;9,3;9]".. --big part
		
		"list[current_player;craft;1.75,0.5;3,3;]"..
		"list[current_player;craftpreview;6.1,1.5;1,1;]"..
		"listring[current_player;main]"..
		"listring[current_player;craft]"

		minetest.show_formspec(player:get_player_name(), "main", form)
	end,
})
minetest.register_craft({
	output = "craftingtable:craftingtable",
	recipe = {
		{"main:wood","main:wood"},
		{"main:wood","main:wood"}
	}
})
