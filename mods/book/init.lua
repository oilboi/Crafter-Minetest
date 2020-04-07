--book is item
--craftable
--save metadata of text
--reload text
--write to make permenant

local open_book_gui = function(itemstack, user)
	local meta = itemstack:get_meta()
	local book_text = meta:get_string("book.book_text")
	if book_text == "" then
		book_text = "Text here"
	end
	local book_title = meta:get_string("book.book_title")
	if book_title == "" then
		book_title = "Title here"
	end
	
	book_writing_formspec = "size[9,8.75]"..
		"background[-0.19,-0.25;9.41,9.49;gui_hb_bg.png]"..
		"style[book.book_text,book.book_title;textcolor=black;border=false;noclip=false]"..
		"textarea[0.3,0;9,0.5;book.book_title;;"..book_title.."]"..
		"textarea[0.3,0.3;9,9;book.book_text;;"..book_text.."]"..
		"button[-0.2,8.3;1,1;book.book_write;write]"..
		"button[8.25,8.3;1,1;book.book_ink;ink  ]"
	minetest.show_formspec(user:get_player_name(), "book.book_gui", book_writing_formspec)
end

local open_book_inked_gui = function(itemstack, user)
	local meta = itemstack:get_meta()
	local book_text = meta:get_string("book.book_text")
	
	local book_title = meta:get_string("book.book_title")
	
	book_writing_formspec = "size[9,8.75]"..
		"background[-0.19,-0.25;9.41,9.49;gui_hb_bg.png]"..
		"style[book.book_text,book.book_title;textcolor=black;border=false;noclip=false]"..
		"textarea[0.3,0;9,0.5;book.book_title;;"..book_title.."]"..
		"textarea[0.3,0.3;9,9;book.book_text;;"..book_text.."]"..
		"button_exit[4,8.3;1,1;close;close]"
		
	minetest.show_formspec(user:get_player_name(), "book.book_gui", book_writing_formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if not formname == "book.book_gui" then return end
	
	if fields["book.book_write"] and fields["book.book_text"] and fields["book.book_text"] then
		local itemstack = ItemStack("book:book")
		local meta = itemstack:get_meta()
		meta:set_string("book.book_text", fields["book.book_text"])
		meta:set_string("book.book_title", fields["book.book_title"])	
		meta:set_string("description", fields["book.book_title"])
		
		player:set_wielded_item(itemstack)
		minetest.close_formspec(player:get_player_name(), "book.book_gui")
	elseif fields["book.book_ink"] and fields["book.book_text"] and fields["book.book_text"] then
		local itemstack = ItemStack("book:book_written")
		local meta = itemstack:get_meta()
		meta:set_string("book.book_text", fields["book.book_text"])
		meta:set_string("book.book_title", fields["book.book_title"])	
		meta:set_string("description", fields["book.book_title"])
		
		player:set_wielded_item(itemstack)
		minetest.close_formspec(player:get_player_name(), "book.book_gui")
	end
end)



minetest.register_craftitem("book:book",{
		description = "Book",
		groups = {book = 1, written = 0},

		inventory_image = "book.png",
		
		on_place = function(itemstack, user, pointed_thing)
			print("make books placable on the ground")
			open_book_gui(itemstack, user)
		end,

		on_secondary_use = function(itemstack, user, pointed_thing)
			open_book_gui(itemstack, user)
		end,
})

minetest.register_craftitem("book:book_written",{
		description = "Book",
		groups = {book = 1, written = 1},

		inventory_image = "book_written.png",
		
		on_place = function(itemstack, user, pointed_thing)
			print("make books placable on the ground")
			open_book_inked_gui(itemstack, user)
		end,

		on_secondary_use = function(itemstack, user, pointed_thing)
			open_book_inked_gui(itemstack, user)
		end,
})

minetest.register_craft({
	output = "book:book",
	recipe = {
		{"main:wood","weather:snowball","main:wood"},
		{"main:wood","weather:snowball","main:wood"},
		{"main:wood","weather:snowball","main:wood"},
	}
})
--book book book