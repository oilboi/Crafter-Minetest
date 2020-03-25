--Too Many Items (TMI)
--[[this is a recreation of an old minecraft mod]]--

--THIS IS EXTREMELY sloppy because it's a prototype
function create_craft_formspec(item)
	local recipe = minetest.get_craft_recipe(item)
	local output = ""
	if recipe.method == "normal" then
		output = "size[17.2,8.75]"..
		"background[-0.19,-0.25;9.41,9.49;gui_hb_bg.png]"..
		"listcolors[#8b8a89;#c9c3c6;#3e3d3e;#000000;#FFFFFF]"..
		"list[current_player;main;0,4.5;9,1;]".. --hot bar
		"list[current_player;main;0,6;9,3;9]".. --big part
		"button[5,3.5;1,1;back;back]"
		
		local width = recipe.width
		local i = 1
		
		local base_x = 0.75
		local base_y = -0.5
		
		for x = 1,width do
		for y = 1,3 do
			for index,item in pairs(recipe.items) do
				if index == i then
					if width > 1 then
						output = output.."item_image_button["..base_x+y..","..base_y+x..";1,1;"..item..";"..item..";]"
					else
						output = output.."item_image_button["..base_x+x..","..base_y+y..";1,1;"..item..";"..item..";]"
					end
				end
			end
			i = i + 1
		end
		end
	end
	return(output)
end


minetest.register_on_player_receive_fields(function(player, formname, fields)
	--print(dump(fields))
	local form
	local id
	if formname == "" then
		form = base_inv
		id = ""
	elseif formname == "crafting" then
		form = crafting_table_inv
		id = "crafting"
	end
	
	
	--"next" button
	if fields.next then
		local page = get_player_page(player)
		
		page = page + 1
		--page loops back to first
		if page > pages then
			page = 0
		end	
		
		set_player_page(player,page)
		
		set_inventory_page(player,form)
		
		minetest.show_formspec(player:get_player_name(),id, form..inv["page_"..page])
	--"prev" button
	elseif fields.prev then
		local page = get_player_page(player)
		
		page = page - 1
		--page loops back to end
		if page < 0 then
			page = pages
		end	
		set_player_page(player,page)
		
		set_inventory_page(player,form)
		
		minetest.show_formspec(player:get_player_name(),id, form..inv["page_"..page])
	elseif fields.back then
		local page = get_player_page(player)
		minetest.show_formspec(player:get_player_name(),id, form..inv["page_"..page])
	--this resets the craft table
	elseif fields.quit then
		local inv = player:get_inventory()
		dump_craft(player)
		inv:set_width("craft", 2)
		inv:set_size("craft", 4)
		--reset the player inv
		set_inventory_page(player,base_inv)
	else
		--local pos = player:getpos()
		
		--minetest.add_item(pos,next(fields))
		--this is not a good idea
		--create packed table to decode instead
		local page = get_player_page(player)
		
		local craft_inv = create_craft_formspec(next(fields))
		
		if craft_inv ~= "" then
			minetest.show_formspec(player:get_player_name(),id, craft_inv..inv["page_"..page])
		end
	end
end)

get_player_page = function(player)
	local meta = player:get_meta()
	return(meta:get_int("page"))
end

set_player_page = function(player,page)
	local meta = player:get_meta()
	meta:set_int("page",page)
end

local max = 7*7
--this is where the main 2x2 formspec is
base_inv = "size[17.2,8.75]"..
    "background[-0.19,-0.25;9.41,9.49;main_inventory.png]"..
    "listcolors[#8b8a89;#c9c3c6;#3e3d3e;#000000;#FFFFFF]"..
    "list[current_player;main;0,4.5;9,1;]".. --hot bar
	"list[current_player;main;0,6;9,3;9]".. --big part
    "list[current_player;craft;2.5,1;2,2;]"..
    "list[current_player;craftpreview;6.1,1.5;1,1;]"..
    "listring[current_player;main]"..
	"listring[current_player;craft]"
--this is the 3x3 crafting table formspec
crafting_table_inv = "size[17.2,8.75]"..
		"background[-0.19,-0.25;9.41,9.49;crafting_inventory_workbench.png]"..
		"listcolors[#8b8a89;#c9c3c6;#3e3d3e;#000000;#FFFFFF]"..
		"list[current_player;main;0,4.5;9,1;]".. --hot bar
		"list[current_player;main;0,6;9,3;9]".. --big part
		"list[current_player;craft;1.75,0.5;3,3;]"..
		"list[current_player;craftpreview;6.1,1.5;1,1;]"..
		"listring[current_player;main]"..
		"listring[current_player;craft]"


--the global page number
pages = 0

--run through the items and then set the pages
minetest.register_on_mods_loaded(function()
local item_counter = 0
inv = {}

local page = 0
inv["page_"..page] = ""

local x = 0
local y = 0

--dump all the items in
for index,data in pairs(minetest.registered_items) do
	local recipe = minetest.get_craft_recipe(data.name)
	--only put in craftable items
	if recipe.method then
		inv["page_"..page] = inv["page_"..page].."item_image_button["..9.25+x..","..y..";1,1;"..data.name..";"..data.name..";]"
		x = x + 1
		if x > 7 then
			x = 0
			y = y + 1
		end
		if y > 7 then
			y = 0
			page = page + 1
			inv["page_"..page] = ""
		end
	end
end

--add buttons and labels
for i = 0,page do
	--set the last page
	inv["page_"..i] = inv["page_"..i].."button[9.25,7.6;2,2;prev;prev]"..
	"button[15.25,7.6;2,2;next;next]"..
	--this is +1 so it makes more sense
	"label[12.75,8.25;page "..(i+1).."/"..(page+1).."]"
end

--override crafting table
minetest.override_item("craftingtable:craftingtable", {
	 on_rightclick = function(pos, node, player, itemstack)
		player:get_inventory():set_width("craft", 3)
		player:get_inventory():set_size("craft", 9)
		local page = get_player_page(player)
		minetest.show_formspec(player:get_player_name(), "crafting", crafting_table_inv..inv["page_"..page])
	end,
})

pages = page
end)

--this is how the player "turns" the page
set_inventory_page = function(player,inventory)
	local page = get_player_page(player)
	player:set_inventory_formspec(inventory..inv["page_"..page])
end

--set new players inventory up
minetest.register_on_joinplayer(function(player)
	set_player_page(player,0) -- this sets the meta "page" to remember what page they're on
	set_inventory_page(player,base_inv) --this sets the "" (inventory button/main) inventory
	
	local inv = player:get_inventory()
	inv:set_width("craft", 2)
	inv:set_width("main", 9)
	inv:set_size("main", 9*4)
	inv:set_size("craft", 4)
	player:hud_set_hotbar_itemcount(9)
	player:hud_set_hotbar_image("inventory_hotbar.png")
	player:hud_set_hotbar_selected_image("hotbar_selected.png")
end)
