local minetest = minetest
minetest.register_on_joinplayer(function(player)
	--add in version info
	player:hud_add({
        hud_elem_type = "text",
        position = {x=1, y=0},
        name = "versionbg",
        text = "Alpha 0.05",
        number = 0x000000,
        offset = {x = -98, y = 20},
        size = { x=2, y=2 },
        z_index = 0,
    })                            
    player:hud_add({
        hud_elem_type = "text",
        position = {x=1, y=0},
        name = "versionfg",
        text = "Alpha 0.05",
        number = 0xFFFFFF,
        offset = {x = -100, y = 18},
        size = { x=2, y=2 },
        z_index = 0,
    }) 
end)
