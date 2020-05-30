-- player/init.lua

dofile(minetest.get_modpath("player_api") .. "/api.lua")

-- Default player appearance
player_api.register_model("character.b3d", {
	animation_speed = 24,
	textures = {"player.png", "blank_skin.png"},
	animations = {
		-- Standard animations.
		stand     = {x = 5,   y = 5},
		die       = {x = 5,   y = 5},
		lay       = {x = 162, y = 162},
		walk      = {x = 168, y = 187},
		mine      = {x = 189, y = 198},
		run       = {x = 189, y = 198},
		walk_mine = {x = 200, y = 219},
		run_mine  = {x = 200, y = 219},
		sit       = {x = 81,  y = 160},
		sneak     = {x = 60,  y = 60},
		sneak_mine_stand = {x=20,y=30},
		sneak_walk= {x = 60,   y = 80},
		sneak_mine_walk= {x = 40,   y = 59},
	},
	collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
	stepheight = 0.6,
	eye_height = 1.47,
})

-- Update appearance when the player joins
minetest.register_on_joinplayer(function(player)
	player_api.player_attached[player:get_player_name()] = false
	player_api.set_model(player, "character.b3d")
	player:set_local_animation(
		{x = 0,   y = 79},
		{x = 168, y = 187},
		{x = 189, y = 198},
		{x = 200, y = 219},
		24
	)
end)

minetest.register_entity("player_api:item", {
	initial_properties = {
		hp_max = 1,
		physical = true,
		collide_with_objects = false,
		collisionbox = {0, 0, 0, 0, 0, 0},
		visual = "wielditem",
		visual_size = {x = 0.21, y = 0.21},
		textures = {""},
		spritediv = {x = 1, y = 1},
		initial_sprite_basepos = {x = 0, y = 0},
		is_visible = true,
		pointable = false,
	},

	itemstring = "",

	set_item = function(self, item)
		local stack = ItemStack(item or self.itemstring)
		
		self.itemstring = stack:to_string()
		

		-- Backwards compatibility: old clients use the texture
		-- to get the type of the item
		local itemname = stack:is_known() and stack:get_name() or "unknown"

		local max_count = stack:get_stack_max()
		local count = math.min(stack:get_count(), max_count)

		local size = 0.21
		local coll_height = size * 0.75
		local def = minetest.registered_nodes[itemname]
		local glow = def and def.light_source

		local is_visible = true
		if self.itemstring == "" then
			-- item not yet known
			is_visible = false
		end

		self.object:set_properties({
			is_visible = is_visible,
			visual = "wielditem",
			textures = {itemname},
			visual_size = {x = size, y = size},
			collisionbox = {-size, -0.21, -size,
				size, coll_height, size},
			selectionbox = {-size, -size, -size, size, size, size},
			--automatic_rotate = math.pi * 0.5 * 0.2 / size,
			wield_item = self.itemstring,
			glow = glow,
		})
	end,

	on_step = function(self, dtime)
		if not self.wielder then
			self.object:remove()
		end
	end,
})
