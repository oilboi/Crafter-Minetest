minetest.register_on_joinplayer(function(player)
	--add in version info
	player:hud_add({
		hud_elem_type = "image",
		position = {x=1,y=0},
		scale = {x=0.75,y=0.75},
		text = "version.png",
		--number = 000000,
		--alignment = {x=-1,y=0},
		offset = {x=-180, y=19},
	})
end)
