local settings = minetest.settings

local old = settings:get("dedicated_server_step")

settings:set("dedicated_server_step", 0.00001)
settings:set("liquid_update", 0.25)
settings:set("abm_interval", 0.25)

print("Changing server step from "..old.." to 0.00001")
print("Changing liquid update to ")


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

print("Max stack set to 1000")

--minetest.register_globalstep(function(dtime)
--      print(settings:get("dedicated_server_step"))
--end)
