local minetest,pairs = minetest,pairs

local tmi_master_inventory = {}
local pool = {}
local max = 7*7
--2x2 formspec
local base_inv = 
"size[17.2,8.75]"..
"background[-0.19,-0.25;9.41,9.49;main_inventory.png]"..
"listcolors[#8b8a89;#c9c3c6;#3e3d3e;#000000;#FFFFFF]"..
"list[current_player;main;0,4.5;9,1;]".. --hot bar
"list[current_player;main;0,6;9,3;9]".. --big part
"list[current_player;craft;2.5,1;2,2;]"..
--armor slots
"list[current_player;armor_head;0.25,0;1,1;]"..
"list[current_player;armor_torso;0.25,1;1,1;]"..
"list[current_player;armor_legs;0.25,2;1,1;]"..
"list[current_player;armor_feet;0.25,3;1,1;]"..
--craft preview with ring
"list[current_player;craftpreview;6.1,1.5;1,1;]"..
"listring[current_player;main]"..
"listring[current_player;craft]"
--this is the 3x3 crafting table formspec
local crafting_table_inv = 
"size[17.2,8.75]"..
"background[-0.19,-0.25;9.41,9.49;crafting_inventory_workbench.png]"..
"listcolors[#8b8a89;#c9c3c6;#3e3d3e;#000000;#FFFFFF]"..
"list[current_player;main;0,4.5;9,1;]".. --hot bar
"list[current_player;main;0,6;9,3;9]".. --big part
"list[current_player;craft;1.75,0.5;3,3;]"..
--armor slots
"list[current_player;armor_head;0.25,0;1,1;]"..
"list[current_player;armor_torso;0.25,1;1,1;]"..
"list[current_player;armor_legs;0.25,2;1,1;]"..
"list[current_player;armor_feet;0.25,3;1,1;]"..
--craft preview with ring
"list[current_player;craftpreview;6.1,1.5;1,1;]"..
"listring[current_player;main]"..
"listring[current_player;craft]"
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

local get_if_group = function(item)
	if item ~= nil and item:sub(1,6) == "group:" then
		local group_name = item:sub(7, item:len())
		local mapped_item = map_group_to_item[group_name]
		if mapped_item ~= nil then
			return(mapped_item)
		end
	end
	return(item)
end


local base_x = 0.75
local base_y = -0.5
local output_constant = 
"listcolors[#8b8a89;#c9c3c6;#3e3d3e;#000000;#FFFFFF]"..
"list[current_player;main;0,4.5;9,1;]"..   --hot bar
"list[current_player;main;0,6;9,3;9]"..    --main inventory
"button[5,3.5;1,1;toomanyitems.back;back]" --back button
local output
local recipe
local usable_recipe
local function create_craft_formspec(item)
	--don't do air
	if item == "" then
		return("")
	end

	recipe = minetest.get_craft_recipe(item)
	
	usable_table = recipe_converter(recipe.items, recipe.width)

	output = output_constant
	
	if recipe.method == "normal" then
		if usable_table then
			--shaped (regular)
			if recipe.width > 0 then
				for x = 1,3 do
					for y = 1,3 do
						item = get_if_group(usable_table[x][y])
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
						item = get_if_group(usable_table[i])
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
		item = recipe.items[1]
		output = output.."item_image_button["..(base_x+2)..","..(base_y+1)..";1,1;"..item..";"..item..";]"
		output = output.."image[2.75,1.5;1,1;default_furnace_fire_fg.png]"
	end
	return(output)
end

local function cheat_button(name)
	if pool[name] and pool[name].cheating then
		return("button[11.5,7.6;2,2;toomanyitems.cheat;cheat:on]")
	else
		return("button[11.5,7.6;2,2;toomanyitems.cheat;cheat:off]")
	end
end


local form
local id
local inv
local item
local stack
local craft_inv
local name
local temp_pool
minetest.register_on_player_receive_fields(function(player, formname, fields)
	name = player:get_player_name()
	temp_pool = pool[name]

	if formname == "" then
		form = base_inv
		id = ""
	elseif formname == "crafting" then
		form = crafting_table_inv
		id = "crafting"
	end
	
	--"next" button
	if fields["toomanyitems.next"] then
		temp_pool.page = temp_pool.page + 1
		--page loops back to first
		if temp_pool.page > tmi_master_inventory.page_limit then
			temp_pool.page = 1
		end	
		minetest.show_formspec(name,id, form..tmi_master_inventory["page_"..temp_pool.page]..cheat_button(name))
		minetest.sound_play("lever", {to_player = name,gain=0.7})
		player:set_inventory_formspec(base_inv..tmi_master_inventory["page_"..temp_pool.page]..cheat_button(name))
	--"prev" button
	elseif fields["toomanyitems.prev"] then
		temp_pool.page = temp_pool.page - 1
		--page loops back to end
		if temp_pool.page < 1 then
			temp_pool.page = tmi_master_inventory.page_limit
		end	
		
		minetest.show_formspec(name,id, form..tmi_master_inventory["page_"..temp_pool.page]..cheat_button(name))
		minetest.sound_play("lever", {to_player = name,gain=0.7})
		player:set_inventory_formspec(base_inv..tmi_master_inventory["page_"..temp_pool.page]..cheat_button(name))
	elseif fields["toomanyitems.back"] then

		minetest.show_formspec(name,id, form..tmi_master_inventory["page_"..temp_pool.page]..cheat_button(name))
		minetest.sound_play("lever", {to_player = name,gain=0.7})
	--this resets the craft table
	elseif fields.quit then
		inv = player:get_inventory()
		dump_craft(player)
		inv:set_width("craft", 2)
		inv:set_size("craft", 4)
		--reset the player inv
		--minetest.show_formspec(name,id, form..tmi_master_inventory["page_"..temp_pool.page]..cheat_button(name))
	elseif fields["toomanyitems.cheat"] then
		--check if the player has the give priv
		if (not temp_pool.cheating and minetest.get_player_privs(name).give == true) or temp_pool.cheating == true then
			temp_pool.cheating = not temp_pool.cheating

			minetest.show_formspec(name,id, form..tmi_master_inventory["page_"..temp_pool.page]..cheat_button(name))
			minetest.sound_play("lever", {to_player = name,gain=0.7})
			player:set_inventory_formspec(base_inv..tmi_master_inventory["page_"..temp_pool.page]..cheat_button(name))
		else
			minetest.chat_send_player(name, "Sorry m8, server says I can't let you do that :(")
			minetest.sound_play("lever", {to_player = name,gain=0.7,pitch=0.7})
		end
	--this is the "cheating" aka giveme function and craft recipe
	elseif fields and type(fields) == "table" and string.match(next(fields),"toomanyitems.") then

		item = string.gsub(next(fields), "toomanyitems.", "")
		stack = ItemStack(item.." 64")
		inv = player:get_inventory()
		if temp_pool.cheating and minetest.get_player_privs(name).give then
			
			--room for item
			if inv and inv:room_for_item("main",stack) then
				inv:add_item("main", stack)
				minetest.sound_play("pickup", {to_player = name,gain=0.7,pitch = math.random(60,100)/100})
			--no room for item
			else
				minetest.chat_send_player(name, "Might want to clear your inventory")
				minetest.sound_play("lever", {to_player = name,gain=0.7,pitch=0.7})
			end

		--this is to get the craft recipe
		else
			craft_inv = create_craft_formspec(item)
			if craft_inv and craft_inv ~= "" then
				minetest.show_formspec(name, id, tmi_master_inventory["page_"..temp_pool.page]..craft_inv..cheat_button(name))
				minetest.sound_play("lever", {to_player = name,gain=0.7})
			end
		end

	end
end)


--run through the items and then set the pages
local item_counter = 0
local page = 1
local x = 0
local y = 0

minetest.register_on_mods_loaded(function()

--sort all items (There is definitely a better way to do this)

--get all craftable items
local all_items_table = {}
for index,data in pairs(minetest.registered_items) do
	if data.name ~= "" then
		local recipe = minetest.get_craft_recipe(data.name)
		--only put in craftable items
		if recipe.method then			
			table.insert(all_items_table,data.name)
		end
	end
end

table.sort(all_items_table)

--dump all the items in

tmi_master_inventory["page_"..page] = "size[17.2,8.75]background[-0.19,-0.25;9.41,9.49;crafting_inventory_workbench.png]"

for _,item in pairs(all_items_table) do
	tmi_master_inventory["page_"..page] = tmi_master_inventory["page_"..page].."item_image_button["..(9.25+x)..","..y..";1,1;"..item..";toomanyitems."..item..";]"
	x = x + 1
	if x > 7 then
		x = 0
		y = y + 1
	end
	if y > 7 then
		y = 0
		page = page + 1
		tmi_master_inventory["page_"..page] = "size[17.2,8.75]background[-0.19,-0.25;9.41,9.49;crafting_inventory_workbench.png]"
	end
end

--add buttons and labels
for i = 1,page do
	--set the last page
	tmi_master_inventory["page_"..i] = tmi_master_inventory["page_"..i].."button[9.25,7.6;2,2;toomanyitems.prev;prev]"..
	"button[15.25,7.6;2,2;toomanyitems.next;next]"..
	--this is +1 so it makes more sense
	"label[13.75,8.25;page "..i.."/"..page.."]"
end

tmi_master_inventory.page_limit = page

--override crafting table
local name
local temp_pool

minetest.override_item("craftingtable:craftingtable", {
	 on_rightclick = function(pos, node, player, itemstack)
		name = player:get_player_name()
		temp_pool = pool[name]
		player:get_inventory():set_width("craft", 3)
		player:get_inventory():set_size("craft", 9)
		minetest.show_formspec(name, "crafting", crafting_table_inv..tmi_master_inventory["page_"..temp_pool.page]..cheat_button(name))
	end
})
end)


--set new players inventory up
local name
local temp_pool
local inv
minetest.register_on_joinplayer(function(player)
	name = player:get_player_name()
	pool[name] = {}
	temp_pool = pool[name]

	temp_pool.page = 1
	temp_pool.cheating = false

	inv = player:get_inventory()
	inv:set_width("craft", 2)
	inv:set_width("main", 9)
	inv:set_size("main", 9*4)
	inv:set_size("craft", 4)

	player:set_inventory_formspec(base_inv..tmi_master_inventory["page_1"]..cheat_button(name))

	player:hud_set_hotbar_itemcount(9)
	player:hud_set_hotbar_image("inventory_hotbar.png")
	player:hud_set_hotbar_selected_image("hotbar_selected.png")
end)

local name
minetest.register_on_leaveplayer(function(player)
	name = player:get_player_name()
	pool[name] = nil
end)