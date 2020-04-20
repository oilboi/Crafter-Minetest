--Too Many Items (TMI)
--[[this is a recreation of an old minecraft mod]]--

local creative_mode = minetest.settings:get_bool("creative_mode")

--THIS IS EXTREMELY sloppy because it's a prototype
minetest.register_on_mods_loaded(function()
	for index,data in pairs(minetest.registered_items) do
		if data.name ~= "" then
			if data.drop and data.drop ~= "" then
				--single drop parents
				if type(data.drop) == "string" then
					--add parent to dropped items
					local droppers = minetest.registered_items[data.drop].parent_dropper
					if not droppers then
						--print(data.name)
						droppers = {}
					end
					
					table.insert(droppers, data.name)
					minetest.override_item(data.drop, {
						parent_dropper = droppers
					})
				--multiple drop parents
				elseif type(data.drop) == "table" then
					if data.drop.items then
						for index2,dropdata in pairs(data.drop.items) do
							if dropdata.items then
								for index3,drop_item in pairs(dropdata.items) do
									--add parent to dropped items
									local droppers = minetest.registered_items[drop_item].parent_dropper
									if not droppers then
										droppers = {}
									end
									
									table.insert(droppers, data.name)
									minetest.override_item(drop_item, {
										parent_dropper = droppers
									})
								end
							end
						end
					end
				end
			end
		end
	end
end)

function minetest.get_dropper_nodes(node)
	return(minetest.registered_items[node].parent_dropper)
end
--this is from Linuxdirk, thank you AspireMint for showing me this
local recipe_converter = function (items, width)
    local usable_recipe = { {}, {}, {} }

    -- The recipe is a shapeless recipe so all items are in one table
    if width == 0 then
        usable_recipe = items
    end

    -- x _ _
    -- x _ _
    -- x _ _
    if width == 1 then
        usable_recipe[1][1] = items[1] or ''
        usable_recipe[2][1] = items[2] or ''
        usable_recipe[3][1] = items[3] or ''
    end

    -- x x _
    -- x x _
    -- x x _
    if width == 2 then
        usable_recipe[1][1] = items[1] or ''
        usable_recipe[1][2] = items[2] or ''
        usable_recipe[2][1] = items[3] or ''
        usable_recipe[2][2] = items[4] or ''
        usable_recipe[3][1] = items[5] or ''
        usable_recipe[3][2] = items[6] or ''
    end

    -- x x x
    -- x x x
    -- x x x
    if width == 3 then
        usable_recipe[1][1] = items[1] or ''
        usable_recipe[1][2] = items[2] or ''
        usable_recipe[1][3] = items[3] or ''
        usable_recipe[2][1] = items[4] or ''
        usable_recipe[2][2] = items[5] or ''
        usable_recipe[2][3] = items[6] or ''
        usable_recipe[3][1] = items[7] or ''
        usable_recipe[3][2] = items[8] or ''
        usable_recipe[3][3] = items[9] or ''
    end

    return(usable_recipe)
end

local map_group_to_item = {
	["coal"]  = "main:coal",
	["glass"] = "main:glass",
	["sand"]  = "main:sand",
	["stick"] = "main:stick",
	["stone"] = "main:cobble",
	["tree"]  = "main:tree",
	["wood"]  = "main:wood"
}

get_if_group = function(item)
	if item ~= nil and item:sub(1,6) == "group:" then
		local group_name = item:sub(7, item:len())
		local mapped_item = map_group_to_item[group_name]
		if mapped_item ~= nil then
			return(mapped_item)
		end
	end
	return(item)
end
	

function create_craft_formspec(item)
	--don't do air
	if item == "" then
		return("")
	end
	local recipe = minetest.get_craft_recipe(item)
	
	local usable_table = recipe_converter(recipe.items, recipe.width)
	output = "size[17.2,8.75]"..
		"background[-0.19,-0.25;9.41,9.49;gui_hb_bg.png]"..
		"listcolors[#8b8a89;#c9c3c6;#3e3d3e;#000000;#FFFFFF]"..
		"list[current_player;main;0,4.5;9,1;]".. --hot bar
		"list[current_player;main;0,6;9,3;9]".. --big part
		"button[5,3.5;1,1;toomanyitems.back;back]" --back button
	
	local base_x = 0.75
	local base_y = -0.5
	if recipe.method == "normal" then
		if usable_table then
			--shaped (regular)
			if recipe.width > 0 then
				for x = 1,3 do
				for y = 1,3 do
					local item = get_if_group(usable_table[x][y])
					if item then
						output = output.."item_image_button["..base_x+y..","..base_y+x..";1,1;"..item..";"..item..";]"
					else
						output = output.."item_image_button["..base_x+y..","..base_y+x..";1,1;;;]"
					end
				end
				end
			--shapeless
			else
				local i = 1
				for x = 1,3 do
				for y = 1,3 do
					local item = get_if_group(usable_table[i])
					if item then
						output = output.."item_image_button["..base_x+y..","..base_y+x..";1,1;"..item..";"..item..";]"
					else
						output = output.."item_image_button["..base_x+y..","..base_y+x..";1,1;;;]"
					end
					i = i + 1
				end
				end
			end
		end
	elseif recipe.method == "cooking" then
		local item = recipe.items[1]
		output = output.."item_image_button["..(base_x+2)..","..(base_y+1)..";1,1;"..item..";"..item..";]"
		output = output.."image[2.75,1.5;1,1;default_furnace_fire_fg.png]"
	--this is an escape to check if diggable
	else
		local dropper = minetest.get_dropper_nodes(item)
		local dug_node = nil
		if type(dropper) == "table" and table.getn(dropper) > 0 then
			local amount_of_droppers = table.getn(dropper)
			dug_node = dropper[math.random(1,amount_of_droppers)]
		else
			--print("failed")
		end		
		if dug_node then
			output = output.."item_image_button["..(base_x+2)..","..(base_y+1)..";1,1;"..dug_node..";"..dug_node..";]"
			output = output.."image[2.75,1.5;1,1;diamondpick.png]"
			
		else
			return("")
		end
	end
	return(output)
end


function show_cheat_button(player)
	local cheat = get_player_cheat(player)
	if cheat == 1 then
		return("button[11.5,7.6;2,2;toomanyitems.cheat;cheat:on]")
	else
		return("button[11.5,7.6;2,2;toomanyitems.cheat;cheat:off]")
	end
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
	
	local cheating = get_player_cheat(player)
	--"next" button
	if fields["toomanyitems.next"] then
		local page = get_player_page(player)
		
		page = page + 1
		--page loops back to first
		if page > pages then
			page = 0
		end	
		
		set_player_page(player,page)
		
		set_inventory_page(player,form)
		local cheat_button = show_cheat_button(player)	
		minetest.show_formspec(player:get_player_name(),id, form..inv["page_"..page]..cheat_button)
		minetest.sound_play("lever", {to_player = player:get_player_name(),gain=0.7})
	--"prev" button
	elseif fields["toomanyitems.prev"] then
		local page = get_player_page(player)
		
		page = page - 1
		--page loops back to end
		if page < 0 then
			page = pages
		end	
		
		set_player_page(player,page)
		set_inventory_page(player,form)
		local cheat_button = show_cheat_button(player)	
		minetest.show_formspec(player:get_player_name(),id, form..inv["page_"..page]..cheat_button)
		minetest.sound_play("lever", {to_player = player:get_player_name(),gain=0.7})
	elseif fields["toomanyitems.back"] then
		local page = get_player_page(player)
		local cheat_button = show_cheat_button(player)
		minetest.show_formspec(player:get_player_name(),id, form..inv["page_"..page]..cheat_button)
		minetest.sound_play("lever", {to_player = player:get_player_name(),gain=0.7})
	--this resets the craft table
	elseif fields.quit then
		local inv = player:get_inventory()
		dump_craft(player)
		inv:set_width("craft", 2)
		inv:set_size("craft", 4)
		--reset the player inv
		set_inventory_page(player,base_inv)
	elseif fields["toomanyitems.cheat"] then
		--check if the player has the give priv
		local privved = minetest.get_player_privs(player:get_player_name()).give
		local cheating = get_player_cheat(player)
		if creative_mode or (cheating == 0 and privved == true) or cheating == 1 then
			local cheating = math.abs(cheating - 1)
			if creative_mode then
				cheating = 1
			end
			set_player_cheat(player,cheating)
			local cheat_button = show_cheat_button(player)
			local page = get_player_page(player)
			minetest.show_formspec(player:get_player_name(),id, form..inv["page_"..page]..cheat_button)
			minetest.sound_play("lever", {to_player = player:get_player_name(),gain=0.7})
		else
			minetest.chat_send_player(player:get_player_name(), minetest.colorize("red", "YOU DO NOT HAVE THE 'GIVE' PRIVELAGE"))
			minetest.sound_play("lever", {to_player = player:get_player_name(),gain=0.7,pitch=0.7})
		end
	--this is the "cheating" aka giveme function and craft recipe
	elseif fields and type(fields) == "table" and string.match(next(fields),"toomanyitems.") then
		local item = string.gsub(next(fields), "toomanyitems.", "")
		local privved = minetest.get_player_privs(player:get_player_name()).give
		local cheating = get_player_cheat(player)


		if creative_mode or (cheating == 1 and privved == true) then
			local pos = player:getpos()
			local inv = player:get_inventory()
			local stack = ItemStack(item.." 64")
			
			--room for item
			if inv and inv:room_for_item("main",stack) then
				inv:add_item("main", stack)
				minetest.sound_play("pickup", {to_player = player:get_player_name(),gain=0.7,pitch = math.random(60,100)/100})
			--no room for item
			else
				local namer = string.upper(minetest.registered_items[item].description)
				minetest.chat_send_player(player:get_player_name(), minetest.colorize("red", "THERE IS NO ROOM FOR "..namer.." IN YOUR INVENTORY!"))
				minetest.sound_play("lever", {to_player = player:get_player_name(),gain=0.7,pitch=0.7})
			end
			--minetest.show_formspec(player:get_player_name(),id, inv["page_"..page])
		--this is to get the craft recipe
		else
			local page = get_player_page(player)
			local craft_inv = create_craft_formspec(item)
			if craft_inv and craft_inv ~= "" then
				local cheat_button = show_cheat_button(player)	
				minetest.show_formspec(player:get_player_name(),id, craft_inv..inv["page_"..page]..cheat_button)
				minetest.sound_play("lever", {to_player = player:get_player_name(),gain=0.7})
			end
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

--

get_player_cheat = function(player)
	local meta = player:get_meta()
	return(meta:get_int("cheating"))
end

set_player_cheat = function(player,truth)
	local meta = player:get_meta()
	meta:set_int("cheating",truth)
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
	if data.name ~= "" then
		local recipe = minetest.get_craft_recipe(data.name)
		--only put in craftable items
		if recipe.method then
			inv["page_"..page] = inv["page_"..page].."item_image_button["..9.25+x..","..y..";1,1;"..data.name..";toomanyitems."..data.name..";]"
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
end

--add buttons and labels
for i = 0,page do
	--set the last page
	inv["page_"..i] = inv["page_"..i].."button[9.25,7.6;2,2;toomanyitems.prev;prev]"..
	"button[15.25,7.6;2,2;toomanyitems.next;next]"..
	--this is +1 so it makes more sense
	"label[13.75,8.25;page "..(i+1).."/"..(page+1).."]"
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
	local cheat = get_player_cheat(player)
	if cheat == 1 then
		inventory = inventory.."button[11.5,7.6;2,2;toomanyitems.cheat;cheat:on]"
	else
		inventory = inventory.."button[11.5,7.6;2,2;toomanyitems.cheat;cheat:off]"
	end
		
	player:set_inventory_formspec(inventory..inv["page_"..page])
end

--set new players inventory up
minetest.register_on_joinplayer(function(player)
	local cheat_mode = 0
	if creative_mode then
		cheat_mode = 1
	end
	set_player_cheat(player, cheat_mode) -- this resets the cheating to false
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
