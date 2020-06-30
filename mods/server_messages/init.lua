local pool = {}

minetest.register_on_joinplayer(function(player)
    local meta = player:get_meta()
    local welcomed = (meta:get_int("welcomed") == 1)
    local name = player:get_player_name()
    pool[name] = minetest.get_us_time()/1000000
    if not welcomed then
        minetest.chat_send_all("Welcome "..name.." to the server!")
        meta:set_int("welcomed", 1)
    else
        minetest.chat_send_all("Welcome back "..name.."!")
    end
end)

local death_messages = {
" got smoked!",
" didn't see that coming!",
" is taking a nap!",
", that looked painful!",
" is pushing up daisies!",
" is lucky there are infinite lives!",
" met their maker!",
" is in pieces!",
" got wrecked!",
" got destroyed!",
" got minced!",
"'s health bar is looking a little empty!",
" turned into a puzzle!",
" is in the Aether now!",
" is in the Nether!",
", how's the Void?",
" dropped their stuff! Go get it!",
" is having a fire sale and everything's free!",
" is doomed!",
", I didn't even know you could have negative health!",
" try not to keep dying!",
" died!",
" probably starved!",
" is seeing how the ground feels!",
" is shutting down!",
}

local leave_messages = {
" logged out.",
" gave up.",
" rage quit.",
"'s game probably crashed.",
" got bored.",
" left.",
" is going IRL.",
" left the matrix.",
" is out.",
}

minetest.register_on_dieplayer(function(player)
    local name = player:get_player_name()
    if (minetest.get_us_time()/1000000)-pool[name] > 0.001 then
        minetest.chat_send_all(name..death_messages[math.random(1,table.getn(death_messages))])
        pool[name] = minetest.get_us_time()/1000000
    end
end)

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    minetest.chat_send_all(name..leave_messages[math.random(1,table.getn(leave_messages))])
end)

