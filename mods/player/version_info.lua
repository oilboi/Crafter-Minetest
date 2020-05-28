minetest.register_on_joinplayer(function(player)
	--add in version info
	player:hud_add({
        hud_elem_type = "text",  -- See HUD element types
        -- Type of element, can be "image", "text", "statbar", or "inventory"

        position = {x=1, y=0},
        -- Left corner position of element

        name = "versionbg",

        --scale = {x = 2, y = 2},

        text = "Alpha 0.05",

        number = 0x000000,--0xFFFFFF,

        --item = 3,
        -- Selected item in inventory. 0 for no item selected.

        --direction = 0,
        -- Direction: 0: left-right, 1: right-left, 2: top-bottom, 3: bottom-top

        offset = {x = -98, y = 20},

        size = { x=2, y=2 },
        -- Size of element in pixels

        z_index = 0,
        -- Z index : lower z-index HUDs are displayed behind higher z-index HUDs
    })                            
    player:hud_add({
        hud_elem_type = "text",  -- See HUD element types
        -- Type of element, can be "image", "text", "statbar", or "inventory"

        position = {x=1, y=0},
        -- Left corner position of element

        name = "versionfg",

        --scale = {x = 2, y = 2},

        text = "Alpha 0.05",

        number = 0xFFFFFF,

        --item = 3,
        -- Selected item in inventory. 0 for no item selected.

        --direction = 0,
        -- Direction: 0: left-right, 1: right-left, 2: top-bottom, 3: bottom-top

        offset = {x = -100, y = 18},

        size = { x=2, y=2 },
        -- Size of element in pixels

        z_index = 0,
        -- Z index : lower z-index HUDs are displayed behind higher z-index HUDs
    }) 
end)
