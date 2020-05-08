-- GENERATED CODE
-- Node Box Editor, version 0.9.0
-- Namespace: test
-- 
-- the higher it is the more it's "eaten"
for i = 0,13 do
	local missing_slice
	if i == 0 then
		missing_slice = "cake_side.png"
	else
		missing_slice = "cake_inner.png"
	end
	minetest.register_node("cake:cake_"..i, {
		description = "Cake",
		tiles = {
			"cake_top.png",
			"cake_bottom.png",
			"cake_side.png",
			"cake_side.png",
			missing_slice,
			"cake_side.png"
		},
		drawtype = "nodebox",
		paramtype = "light",
		node_box = {
			type = "fixed",
			fixed = {
				{-7/16, -8/16, -7/16, 7/16, -1/16, (7-i)/16}, -- Cake
			}
		},
		drop = "",
		sounds = main.woolSound(),
		groups = {wool=1,cake=i,falling_node=1,satiation=5,hunger=3},
		on_construct = function(pos)
			--randomly cake eats itself
			if math.random() > 0.995 then
				minetest.set_node(pos, {name="cake:cursed_cake_0"})
			end
		end,
		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			minetest.eat_food(clicker,node)
			--clicker:set_hp(clicker:get_hp()+5)
			if i == 13 then
		        minetest.sound_play("eat_finish",{pos=pos,gain=0.2,pitch=math.random(90,100)/100})
		        minetest.remove_node(pos)
		        return
	        else
		        minetest.sound_play("eat",{pos=pos,gain=0.2,pitch=math.random(90,100)/100})
		        minetest.set_node(pos, {name="cake:cake_"..i+1})
	        end
		end,
	})
end

for i = 0,13 do
	local missing_slice
	if i == 0 then
		missing_slice = "cake_side.png^[colorize:red:140"
	else
		missing_slice = "cake_inner.png^[colorize:red:140"
	end
	minetest.register_node("cake:cursed_cake_"..i, {
		description = "CURSED CAKE",
		tiles = {
			"cake_top.png^[colorize:red:140",
			"cake_bottom.png^[colorize:red:140",
			"cake_side.png^[colorize:red:140",
			"cake_side.png^[colorize:red:140",
			missing_slice,
			"cake_side.png^[colorize:red:140"
		},
		drawtype = "nodebox",
		paramtype = "light",
		node_box = {
			type = "fixed",
			fixed = {
				{-7/16, -8/16, -7/16, 7/16, -1/16, (7-i)/16}, -- Cake
			}
		},
		drop = "",
		sounds = main.woolSound(),
		groups = {wool=1,cursed_cake=i,falling_node=1},
		on_construct = function(pos)
			local timer = minetest.get_node_timer(pos)
			timer:start(0.2)
		end,
		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			clicker:set_hp(clicker:get_hp()-5)
		end,
		on_timer = function(pos, elapsed)
			if i == 13 then 
		        minetest.sound_play("eat_finish",{pos=pos,gain=0.2,pitch=math.random(90,100)/100}) 
		        minetest.remove_node(pos)
		        return
	        else
		        minetest.sound_play("eat",{pos=pos,gain=0.2,pitch=math.random(90,100)/100})
		        minetest.set_node(pos, {name="cake:cursed_cake_"..i+1})
	        end
		end,
	})
end


minetest.register_craft({
	output = "cake:cake_0",
	recipe = {
		{"weather:snowball","weather:snowball","weather:snowball"},
		{"farming:wheat","farming:wheat","farming:wheat"},
	}
})


