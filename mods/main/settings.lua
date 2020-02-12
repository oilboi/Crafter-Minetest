local settings = minetest.settings

local old = settings:get("dedicated_server_step")

settings:set("dedicated_server_step", 0.00001)


print("Changing server step from "..old.." to 0.00001")


--make stack max 1000 for everything
minetest.register_on_mods_loaded(function()
	for name,_ in pairs(minetest.registered_nodes) do
		minetest.override_item(name, {
			stack_max = 1000,
		})
	end
	for name,_ in pairs(minetest.registered_craftitems) do
		minetest.override_item(name, {
			stack_max = 1000,
		})
	end
end)

--minetest.register_globalstep(function(dtime)
--	print(settings:get("dedicated_server_step"))
--end)
