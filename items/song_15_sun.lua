local item = ...
local game = item:get_game()
local config = require("items/song_manager")

local properties = {
	savegame_variable = "possession_song_15",
  music = "items/ocarina/song/15_sun",
	type = "skip_dialogue",
	effect = function()
		item:song_effect()
	end,
	duration = 5000,
	demo_duration = 4000,
}

function item:song_effect()
	game:switch_time_of_day()
end

config:create(item, properties)