minetest.register_chatcommand("weather", {
	params = "<mobname>",
	description = "Spawn a mob",
	privs = {server = true},
	func = function( name, weather)
		if weather == "0" or weather == "clear" then
			weather_type = 0
			function_send_weather_type()
			update_player_sky()
			minetest.chat_send_all(name.." has set the weather to clear!")
		elseif weather == "1" or weather == "snow" then
			weather_type = 1
			function_send_weather_type()
			minetest.chat_send_all(name.." has set the weather to snow!")
			update_player_sky()
		elseif  weather == "2" or weather == "rain" then
			weather_type = 2
			function_send_weather_type()
			update_player_sky()
			minetest.chat_send_all(name.." has set the weather to rain!")
		elseif weather == "" then
			minetest.chat_send_player(name, "Possible weather types are: 0,clear,1,snow,2,rain")
		else
			minetest.chat_send_player(name, '"'..weather..'"'.." is not a registered weather type!")
		end
	end,
})
