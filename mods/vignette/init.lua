function joinplayer (player)
  player:hud_add({
    hud_elem_type = "image",
    position = {x = 0.5, y = 0.5},
    scale = {
	x = -100.5,
	y = -100.5
    },
    text = "vignette.png"
  })
end

minetest.register_on_joinplayer(joinplayer)
	
